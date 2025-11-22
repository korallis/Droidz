"""
Validators for checking component compatibility and converted prompts
"""

import re
from pathlib import Path
from typing import List, Dict, Optional
from dataclasses import dataclass
from enum import Enum


class ValidationSeverity(Enum):
    """Severity levels for validation issues"""
    ERROR = "error"      # Will not work
    WARNING = "warning"  # May have issues
    INFO = "info"        # FYI only


@dataclass
class ValidationIssue:
    """A validation issue found in a component"""
    severity: ValidationSeverity
    message: str
    line_number: Optional[int] = None
    suggestion: Optional[str] = None


@dataclass
class ValidationResult:
    """Result of validating a component"""
    valid: bool
    issues: List[ValidationIssue]
    component_name: str
    
    @property
    def has_errors(self) -> bool:
        """Check if there are any errors"""
        return any(i.severity == ValidationSeverity.ERROR for i in self.issues)
    
    @property
    def has_warnings(self) -> bool:
        """Check if there are any warnings"""
        return any(i.severity == ValidationSeverity.WARNING for i in self.issues)
    
    @property
    def error_count(self) -> int:
        """Count of errors"""
        return sum(1 for i in self.issues if i.severity == ValidationSeverity.ERROR)
    
    @property
    def warning_count(self) -> int:
        """Count of warnings"""
        return sum(1 for i in self.issues if i.severity == ValidationSeverity.WARNING)


class CodexPromptValidator:
    """Validates Codex CLI prompts for compatibility"""
    
    def __init__(self):
        # Patterns that indicate incompatibility
        self.error_patterns = [
            (r'!`', "Direct shell execution (!`...`) not supported in Codex CLI"),
            (r'^\s*model:\s*inherit', "Model inheritance syntax not applicable in Codex"),
            (r'tools:\s*\[', "Tool array specification not applicable in Codex"),
        ]
        
        # Patterns that may cause issues
        self.warning_patterns = [
            (r'if\s+\[\s+.*?\]\s*;?\s*then', "Complex bash conditionals may not work as expected"),
            (r'for\s+\w+\s+in\s+', "Bash loops may not work as expected"),
            (r'while\s+\[', "While loops may not work as expected"),
            (r'\|\|', "OR operators (||) in complex conditions may not work"),
            (r'&&.*&&', "Chained AND operators may not work as expected"),
            (r'Factory\.ai', "Factory.ai-specific references should be removed"),
            (r'TodoWrite', "TodoWrite tool not available in Codex CLI"),
            (r'ApplyPatch', "ApplyPatch tool not available in Codex CLI"),
        ]
        
        # Info patterns
        self.info_patterns = [
            (r'Execute\(', "Execute tool calls should be described as instructions"),
            (r'spawn.*agent', "Agent spawning not supported (sequential only)"),
        ]
    
    def validate(self, content: str, component_name: str) -> ValidationResult:
        """Validate content for Codex CLI compatibility"""
        issues = []
        lines = content.split('\n')
        
        # Check for errors
        for pattern, message in self.error_patterns:
            matches = re.finditer(pattern, content, re.MULTILINE)
            for match in matches:
                line_num = content[:match.start()].count('\n') + 1
                issues.append(ValidationIssue(
                    severity=ValidationSeverity.ERROR,
                    message=message,
                    line_number=line_num,
                    suggestion="Remove or convert to Codex-compatible format"
                ))
        
        # Check for warnings
        for pattern, message in self.warning_patterns:
            matches = re.finditer(pattern, content, re.MULTILINE | re.IGNORECASE)
            for match in matches:
                line_num = content[:match.start()].count('\n') + 1
                issues.append(ValidationIssue(
                    severity=ValidationSeverity.WARNING,
                    message=message,
                    line_number=line_num,
                    suggestion="Consider simplifying to high-level instructions"
                ))
        
        # Check for info
        for pattern, message in self.info_patterns:
            matches = re.finditer(pattern, content, re.MULTILINE | re.IGNORECASE)
            for match in matches:
                line_num = content[:match.start()].count('\n') + 1
                issues.append(ValidationIssue(
                    severity=ValidationSeverity.INFO,
                    message=message,
                    line_number=line_num
                ))
        
        # Check frontmatter
        fm_issues = self._validate_frontmatter(content)
        issues.extend(fm_issues)
        
        # Validation passes if no errors
        valid = not any(i.severity == ValidationSeverity.ERROR for i in issues)
        
        return ValidationResult(
            valid=valid,
            issues=issues,
            component_name=component_name
        )
    
    def _validate_frontmatter(self, content: str) -> List[ValidationIssue]:
        """Validate frontmatter structure"""
        issues = []
        
        if not content.startswith('---'):
            issues.append(ValidationIssue(
                severity=ValidationSeverity.WARNING,
                message="Missing frontmatter (recommended for Codex prompts)",
                suggestion="Add frontmatter with 'description' field"
            ))
            return issues
        
        parts = content.split('---', 2)
        if len(parts) < 3:
            issues.append(ValidationIssue(
                severity=ValidationSeverity.WARNING,
                message="Malformed frontmatter",
                suggestion="Ensure frontmatter is enclosed in --- markers"
            ))
            return issues
        
        frontmatter = parts[1]
        
        # Check for description
        if 'description:' not in frontmatter:
            issues.append(ValidationIssue(
                severity=ValidationSeverity.WARNING,
                message="Missing 'description' in frontmatter",
                suggestion="Add 'description: <your description>'"
            ))
        
        return issues
    
    def validate_file(self, file_path: Path) -> ValidationResult:
        """Validate a file"""
        if not file_path.exists():
            return ValidationResult(
                valid=False,
                issues=[ValidationIssue(
                    severity=ValidationSeverity.ERROR,
                    message=f"File not found: {file_path}"
                )],
                component_name=file_path.name
            )
        
        try:
            content = file_path.read_text()
            return self.validate(content, file_path.name)
        except Exception as e:
            return ValidationResult(
                valid=False,
                issues=[ValidationIssue(
                    severity=ValidationSeverity.ERROR,
                    message=f"Error reading file: {str(e)}"
                )],
                component_name=file_path.name
            )


class DependencyValidator:
    """Validates system dependencies"""
    
    def validate_node_version(self, version_string: Optional[str]) -> ValidationResult:
        """Validate Node.js version for Codex CLI"""
        issues = []
        
        if not version_string:
            issues.append(ValidationIssue(
                severity=ValidationSeverity.ERROR,
                message="Node.js not found",
                suggestion="Install Node.js 18+ for Codex CLI support"
            ))
            return ValidationResult(valid=False, issues=issues, component_name="Node.js")
        
        try:
            # Extract major version
            version = version_string.lstrip('v').split('.')[0]
            major = int(version)
            
            if major < 18:
                issues.append(ValidationIssue(
                    severity=ValidationSeverity.ERROR,
                    message=f"Node.js {major} is too old (require 18+)",
                    suggestion="Upgrade Node.js to version 18 or higher"
                ))
                return ValidationResult(valid=False, issues=issues, component_name="Node.js")
            
            elif major >= 20:
                issues.append(ValidationIssue(
                    severity=ValidationSeverity.INFO,
                    message=f"Node.js {major} detected (recommended)"
                ))
            
        except (ValueError, IndexError):
            issues.append(ValidationIssue(
                severity=ValidationSeverity.WARNING,
                message="Could not parse Node.js version",
                suggestion="Verify Node.js installation with 'node --version'"
            ))
            return ValidationResult(valid=True, issues=issues, component_name="Node.js")
        
        return ValidationResult(valid=True, issues=issues, component_name="Node.js")
    
    def validate_codex_installation(self, codex_path: Optional[str]) -> ValidationResult:
        """Validate Codex CLI installation"""
        issues = []
        
        if not codex_path:
            issues.append(ValidationIssue(
                severity=ValidationSeverity.WARNING,
                message="Codex CLI not found",
                suggestion="Install Codex CLI to use converted prompts: npm install -g @openai/codex"
            ))
            return ValidationResult(valid=True, issues=issues, component_name="Codex CLI")
        
        issues.append(ValidationIssue(
            severity=ValidationSeverity.INFO,
            message=f"Codex CLI found at {codex_path}"
        ))
        
        return ValidationResult(valid=True, issues=issues, component_name="Codex CLI")


class BatchValidator:
    """Batch validation of multiple components"""
    
    def __init__(self):
        self.prompt_validator = CodexPromptValidator()
        self.dep_validator = DependencyValidator()
    
    def validate_directory(self, directory: Path) -> Dict[str, ValidationResult]:
        """Validate all markdown files in a directory"""
        results = {}
        
        if not directory.exists():
            return results
        
        for md_file in directory.glob('*.md'):
            result = self.prompt_validator.validate_file(md_file)
            results[md_file.name] = result
        
        return results
    
    def generate_report(self, results: Dict[str, ValidationResult]) -> str:
        """Generate a validation report"""
        lines = []
        lines.append("# Validation Report")
        lines.append("")
        
        total_files = len(results)
        valid_files = sum(1 for r in results.values() if r.valid)
        total_errors = sum(r.error_count for r in results.values())
        total_warnings = sum(r.warning_count for r in results.values())
        
        lines.append(f"**Files Validated**: {total_files}")
        lines.append(f"**Valid**: {valid_files}")
        lines.append(f"**Total Errors**: {total_errors}")
        lines.append(f"**Total Warnings**: {total_warnings}")
        lines.append("")
        
        # List files with issues
        if total_errors > 0 or total_warnings > 0:
            lines.append("## Issues Found")
            lines.append("")
            
            for filename, result in sorted(results.items()):
                if result.issues:
                    lines.append(f"### {filename}")
                    
                    for issue in result.issues:
                        icon = "❌" if issue.severity == ValidationSeverity.ERROR else "⚠️" if issue.severity == ValidationSeverity.WARNING else "ℹ️"
                        line_info = f" (line {issue.line_number})" if issue.line_number else ""
                        lines.append(f"- {icon} {issue.message}{line_info}")
                        
                        if issue.suggestion:
                            lines.append(f"  💡 {issue.suggestion}")
                    
                    lines.append("")
        else:
            lines.append("✅ All files validated successfully!")
        
        return '\n'.join(lines)
