"""
Component converters for transforming Claude Code components to Codex CLI prompts
"""

import re
from pathlib import Path
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass


@dataclass
class ConversionResult:
    """Result of a conversion operation"""
    success: bool
    content: str
    warnings: List[str] = None
    metadata: Dict[str, str] = None
    
    def __post_init__(self):
        if self.warnings is None:
            self.warnings = []
        if self.metadata is None:
            self.metadata = {}


class CommandToPromptConverter:
    """Converts Claude Code commands to Codex CLI prompts"""
    
    def __init__(self):
        self.shell_command_pattern = re.compile(r'!`([^`]+)`')
        self.complex_bash_patterns = [
            r'if\s+\[',  # if statements
            r'for\s+\w+\s+in',  # for loops
            r'while\s+\[',  # while loops
            r'\|\|',  # OR operators
            r'&&',  # AND operators (when complex)
        ]
    
    def convert(self, source_path: Path) -> ConversionResult:
        """Convert a Claude Code command to Codex CLI prompt"""
        if not source_path.exists():
            return ConversionResult(
                success=False,
                content="",
                warnings=[f"Source file not found: {source_path}"]
            )
        
        try:
            content = source_path.read_text()
            
            # Extract frontmatter
            frontmatter, body = self._extract_frontmatter(content)
            
            # Convert shell commands to instructions
            converted_body, warnings = self._convert_shell_commands(body)
            
            # Rebuild with frontmatter
            result = self._rebuild_with_frontmatter(frontmatter, converted_body)
            
            return ConversionResult(
                success=True,
                content=result,
                warnings=warnings,
                metadata={'source': str(source_path)}
            )
            
        except Exception as e:
            return ConversionResult(
                success=False,
                content="",
                warnings=[f"Conversion error: {str(e)}"]
            )
    
    def _extract_frontmatter(self, content: str) -> Tuple[Dict[str, str], str]:
        """Extract YAML frontmatter from markdown"""
        frontmatter = {}
        body = content
        
        if content.startswith('---'):
            parts = content.split('---', 2)
            if len(parts) >= 3:
                # Parse frontmatter (simple key: value parsing)
                frontmatter_text = parts[1].strip()
                for line in frontmatter_text.split('\n'):
                    if ':' in line:
                        key, value = line.split(':', 1)
                        frontmatter[key.strip()] = value.strip()
                
                body = parts[2].strip()
        
        return frontmatter, body
    
    def _convert_shell_commands(self, content: str) -> Tuple[str, List[str]]:
        """Convert shell commands (!`...`) to descriptive instructions"""
        warnings = []
        converted = content
        
        # Find all shell commands
        matches = list(self.shell_command_pattern.finditer(content))
        
        if not matches:
            return converted, warnings
        
        # Check for complex bash patterns
        for match in matches:
            command = match.group(1)
            
            # Check if command is complex
            is_complex = any(re.search(pattern, command) for pattern in self.complex_bash_patterns)
            
            if is_complex:
                warnings.append(
                    f"Complex bash detected: {command[:50]}... "
                    "Converted to high-level instruction"
                )
        
        # Convert each shell command to instruction
        for match in reversed(matches):  # Reverse to maintain positions
            command = match.group(1)
            instruction = self._shell_command_to_instruction(command)
            
            # Replace in content
            start, end = match.span()
            converted = converted[:start] + instruction + converted[end:]
        
        return converted, warnings
    
    def _shell_command_to_instruction(self, command: str) -> str:
        """Convert a shell command to a natural language instruction"""
        command = command.strip()
        
        # Common patterns
        if command.startswith('echo'):
            # Extract message
            msg = command.replace('echo', '').strip().strip('"\'')
            return f"\n{msg}\n"
        
        elif 'npx eslint' in command:
            return "\n**Run ESLint:**\n- Command: `npx eslint .`\n- Report any errors found\n- Skip gracefully if no ESLint config\n"
        
        elif 'npx tsc' in command:
            return "\n**Run TypeScript compiler:**\n- Command: `npx tsc --noEmit`\n- Show type errors if any\n- Skip gracefully if no tsconfig.json\n"
        
        elif 'npx prettier' in command:
            return "\n**Run Prettier:**\n- Command: `npx prettier --check .`\n- List files needing formatting\n- Skip gracefully if no Prettier config\n"
        
        elif 'npm test' in command or 'bun test' in command:
            return "\n**Run tests:**\n- Command: `npm test` (or `bun test`)\n- Show test results\n- Skip gracefully if no test script\n"
        
        elif 'command -v' in command:
            # Tool detection
            tool = command.split()[-1] if command.split() else 'tool'
            return f"\nCheck if `{tool}` is installed (use `command -v {tool}`).\n"
        
        elif 'mkdir' in command:
            # Directory creation
            dirs = command.replace('mkdir', '').replace('-p', '').strip()
            return f"\nCreate directory structure: `{dirs}`\n"
        
        elif 'cat >' in command or 'cat >>' in command:
            # File creation
            return "\nCreate/append to file with appropriate content.\n"
        
        else:
            # Generic command
            return f"\nRun command: `{command}`\n(Describe results)\n"
    
    def _rebuild_with_frontmatter(self, frontmatter: Dict[str, str], body: str) -> str:
        """Rebuild markdown with frontmatter"""
        if not frontmatter:
            return body
        
        # Build frontmatter section
        fm_lines = ['---']
        for key, value in frontmatter.items():
            fm_lines.append(f"{key}: {value}")
        fm_lines.append('---')
        
        return '\n'.join(fm_lines) + '\n\n' + body


class AgentToPromptConverter:
    """Converts specialist agents/droids to Codex CLI prompts"""
    
    def convert(self, source_path: Path) -> ConversionResult:
        """Convert an agent definition to Codex prompt"""
        if not source_path.exists():
            return ConversionResult(
                success=False,
                content="",
                warnings=[f"Source file not found: {source_path}"]
            )
        
        try:
            content = source_path.read_text()
            
            # Extract frontmatter
            frontmatter, body = self._extract_frontmatter(content)
            
            # Convert to Codex-compatible prompt
            converted = self._convert_agent_body(body, frontmatter)
            
            # Build Codex frontmatter
            codex_frontmatter = self._build_codex_frontmatter(frontmatter)
            
            result = f"{codex_frontmatter}\n\n{converted}"
            
            return ConversionResult(
                success=True,
                content=result,
                warnings=[],
                metadata={
                    'source': str(source_path),
                    'original_name': frontmatter.get('name', 'unknown')
                }
            )
            
        except Exception as e:
            return ConversionResult(
                success=False,
                content="",
                warnings=[f"Conversion error: {str(e)}"]
            )
    
    def _extract_frontmatter(self, content: str) -> Tuple[Dict[str, str], str]:
        """Extract YAML frontmatter"""
        frontmatter = {}
        body = content
        
        if content.startswith('---'):
            parts = content.split('---', 2)
            if len(parts) >= 3:
                frontmatter_text = parts[1].strip()
                for line in frontmatter_text.split('\n'):
                    if ':' in line:
                        key, value = line.split(':', 1)
                        frontmatter[key.strip()] = value.strip()
                
                body = parts[2].strip()
        
        return frontmatter, body
    
    def _build_codex_frontmatter(self, original_fm: Dict[str, str]) -> str:
        """Build Codex-compatible frontmatter"""
        description = original_fm.get('description', 'Specialist agent')
        
        # Clean up description (remove YAML multiline markers)
        description = description.replace('|', '').strip()
        
        # Build frontmatter
        lines = [
            '---',
            f'description: {description}',
            'argument-hint: [TASK=<description>]',
            '---'
        ]
        
        return '\n'.join(lines)
    
    def _convert_agent_body(self, body: str, frontmatter: Dict[str, str]) -> str:
        """Convert agent body to Codex prompt format"""
        # Remove tool-specific sections (not applicable in Codex)
        body = self._remove_tool_sections(body)
        
        # Remove Factory.ai specific notes
        body = self._remove_factory_specific_notes(body)
        
        # Simplify to high-level workflow
        body = self._simplify_to_workflow(body)
        
        return body
    
    def _remove_tool_sections(self, body: str) -> str:
        """Remove tool-specific sections"""
        # Remove "Your Available Tools" sections
        body = re.sub(
            r'## Your Available Tools.*?(?=##|\Z)',
            '',
            body,
            flags=re.DOTALL
        )
        
        # Remove MCP tool warnings
        body = re.sub(
            r'⚠️ \*\*CRITICAL: Do NOT call MCP tools.*?(?=##|\Z)',
            '',
            body,
            flags=re.DOTALL
        )
        
        return body
    
    def _remove_factory_specific_notes(self, body: str) -> str:
        """Remove Factory.ai specific implementation notes"""
        # Remove model: inherit notes
        body = re.sub(r'model: inherit.*?\n', '', body)
        
        # Remove tool array references
        body = re.sub(r'\[\"Read\", \"Execute\".*?\]', '', body)
        
        return body
    
    def _simplify_to_workflow(self, body: str) -> str:
        """Simplify to high-level workflow instructions"""
        # Keep main sections, remove implementation details
        # This is a basic implementation - can be enhanced
        return body


class SkillsToAgentsMDConverter:
    """Converts skills to AGENTS.md format for Codex CLI"""
    
    def convert_multiple(self, skill_paths: List[Path]) -> ConversionResult:
        """Convert multiple skills into a single AGENTS.md"""
        try:
            sections = []
            warnings = []
            
            # Group skills by category
            by_category = self._group_by_category(skill_paths)
            
            # Build AGENTS.md content
            content_parts = [
                "# AGENTS.md - Project Instructions for Codex CLI",
                "",
                "This file contains development guidelines, best practices, and skills",
                "that Codex CLI will use when working on this project.",
                "",
                "---",
                ""
            ]
            
            # Add each category
            for category, skills in sorted(by_category.items()):
                content_parts.append(f"## {category}")
                content_parts.append("")
                
                for skill_path in skills:
                    skill_content = self._extract_skill_content(skill_path)
                    if skill_content:
                        content_parts.append(skill_content)
                        content_parts.append("")
                    else:
                        warnings.append(f"Could not extract content from {skill_path.name}")
            
            result = '\n'.join(content_parts)
            
            return ConversionResult(
                success=True,
                content=result,
                warnings=warnings,
                metadata={'skill_count': len(skill_paths)}
            )
            
        except Exception as e:
            return ConversionResult(
                success=False,
                content="",
                warnings=[f"Conversion error: {str(e)}"]
            )
    
    def _group_by_category(self, skill_paths: List[Path]) -> Dict[str, List[Path]]:
        """Group skills by category based on name"""
        categories = {
            'Languages & Frameworks': [],
            'Testing & Quality': [],
            'Development Practices': [],
            'Architecture & Design': [],
            'Tools & Infrastructure': [],
            'Other': []
        }
        
        for path in skill_paths:
            name = path.stem.lower()
            
            if any(x in name for x in ['typescript', 'javascript', 'python', 'react', 'nextjs', 'vue']):
                categories['Languages & Frameworks'].append(path)
            elif any(x in name for x in ['test', 'debug', 'coverage']):
                categories['Testing & Quality'].append(path)
            elif any(x in name for x in ['tdd', 'systematic', 'refactor', 'pattern']):
                categories['Development Practices'].append(path)
            elif any(x in name for x in ['architecture', 'design', 'api', 'database']):
                categories['Architecture & Design'].append(path)
            elif any(x in name for x in ['docker', 'ci', 'deploy', 'git']):
                categories['Tools & Infrastructure'].append(path)
            else:
                categories['Other'].append(path)
        
        # Remove empty categories
        return {k: v for k, v in categories.items() if v}
    
    def _extract_skill_content(self, skill_path: Path) -> Optional[str]:
        """Extract skill content without frontmatter"""
        try:
            content = skill_path.read_text()
            
            # Remove frontmatter
            if content.startswith('---'):
                parts = content.split('---', 2)
                if len(parts) >= 3:
                    content = parts[2].strip()
            
            # Add skill name as subsection
            skill_name = skill_path.stem.replace('-', ' ').title()
            return f"### {skill_name}\n\n{content}"
            
        except Exception:
            return None


class ComponentConverter:
    """Main converter class that delegates to specific converters"""
    
    def __init__(self):
        self.command_converter = CommandToPromptConverter()
        self.agent_converter = AgentToPromptConverter()
        self.skills_converter = SkillsToAgentsMDConverter()
    
    def convert_command(self, source_path: Path) -> ConversionResult:
        """Convert a command to Codex prompt"""
        return self.command_converter.convert(source_path)
    
    def convert_agent(self, source_path: Path) -> ConversionResult:
        """Convert an agent to Codex prompt"""
        return self.agent_converter.convert(source_path)
    
    def convert_skills_to_agents_md(self, skill_paths: List[Path]) -> ConversionResult:
        """Convert skills to AGENTS.md"""
        return self.skills_converter.convert_multiple(skill_paths)
    
    def batch_convert_commands(self, source_dir: Path, output_dir: Path) -> Dict[str, ConversionResult]:
        """Convert all commands in a directory"""
        results = {}
        
        if not source_dir.exists():
            return results
        
        for cmd_file in source_dir.glob('*.md'):
            result = self.convert_command(cmd_file)
            results[cmd_file.name] = result
            
            if result.success and output_dir:
                output_file = output_dir / cmd_file.name
                output_file.parent.mkdir(parents=True, exist_ok=True)
                output_file.write_text(result.content)
        
        return results
    
    def batch_convert_agents(self, source_dir: Path, output_dir: Path) -> Dict[str, ConversionResult]:
        """Convert all agents in a directory"""
        results = {}
        
        if not source_dir.exists():
            return results
        
        for agent_file in source_dir.glob('*.md'):
            result = self.convert_agent(agent_file)
            results[agent_file.name] = result
            
            if result.success and output_dir:
                # Remove 'droidz-' prefix for cleaner names
                output_name = agent_file.name.replace('droidz-', '')
                output_file = output_dir / output_name
                output_file.parent.mkdir(parents=True, exist_ok=True)
                output_file.write_text(result.content)
        
        return results
