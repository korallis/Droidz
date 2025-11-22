"""
Codex CLI installer - handles installation of Droidz components for Codex CLI
"""

import os
import shutil
from pathlib import Path
from typing import List, Dict, Optional
from dataclasses import dataclass

from .components import Component, ComponentType
from .converters import ComponentConverter
from .validators import CodexPromptValidator, BatchValidator
from .compatibility import DependencyManager


@dataclass
class InstallationResult:
    """Result of installation operation"""
    success: bool
    installed_components: List[str]
    failed_components: List[str]
    warnings: List[str]
    paths_created: List[Path]


class CodexInstaller:
    """Handles installation for Codex CLI"""
    
    def __init__(self, dry_run: bool = False):
        self.dry_run = dry_run
        self.deps = DependencyManager()
        self.converter = ComponentConverter()
        self.validator = CodexPromptValidator()
        self.batch_validator = BatchValidator()
        
        # Paths
        self.codex_home = Path(self.deps.get_codex_home())
        self.prompts_dir = self.codex_home / "prompts"
        self.project_root = Path.cwd()
        self.source_root = Path(__file__).parent.parent  # Droidz repo root
        
    def install(self, components: List[Component]) -> InstallationResult:
        """Install selected components for Codex CLI"""
        installed = []
        failed = []
        warnings = []
        paths_created = []
        
        print("\n📦 Installing for Codex CLI...")
        print()
        
        # 1. Create directory structure
        print("  🗂️  Creating directory structure...")
        dirs_created = self._create_directory_structure()
        paths_created.extend(dirs_created)
        print(f"     ✓ Created {len(dirs_created)} directories")
        
        # 2. Convert and install commands
        commands = [c for c in components if c.type == ComponentType.COMMAND]
        if commands:
            print(f"\n  🔄 Converting commands → prompts ({len(commands)})...")
            cmd_results = self._install_commands(commands)
            installed.extend(cmd_results['installed'])
            failed.extend(cmd_results['failed'])
            warnings.extend(cmd_results['warnings'])
            paths_created.extend(cmd_results['paths'])
        
        # 3. Convert and install agents
        agents = [c for c in components if c.type == ComponentType.AGENT]
        if agents:
            print(f"\n  🤖 Converting agents → prompts ({len(agents)})...")
            agent_results = self._install_agents(agents)
            installed.extend(agent_results['installed'])
            failed.extend(agent_results['failed'])
            warnings.extend(agent_results['warnings'])
            paths_created.extend(agent_results['paths'])
        
        # 4. Create AGENTS.md with embedded skills
        skills = [c for c in components if c.type == ComponentType.SKILL]
        if skills or any(c.type == ComponentType.AGENT for c in components):
            print(f"\n  📝 Creating AGENTS.md...")
            agents_md_result = self._create_agents_md(skills)
            if agents_md_result['success']:
                installed.append("AGENTS.md")
                paths_created.append(agents_md_result['path'])
                print(f"     ✓ Created AGENTS.md")
            else:
                failed.append("AGENTS.md")
                warnings.extend(agents_md_result['warnings'])
        
        # 5. Create specs system
        specs = [c for c in components if c.type == ComponentType.SPEC]
        if specs:
            print(f"\n  📋 Creating .droidz/specs/ structure...")
            specs_result = self._create_specs_system()
            if specs_result['success']:
                installed.append(".droidz/specs/")
                paths_created.extend(specs_result['paths'])
                print(f"     ✓ Created specs system")
            else:
                failed.append(".droidz/specs/")
                warnings.extend(specs_result['warnings'])
        
        # 6. Validate installed prompts
        if not self.dry_run:
            print(f"\n  ✅ Validating installed prompts...")
            validation_results = self.batch_validator.validate_directory(self.prompts_dir)
            validation_warnings = self._process_validation_results(validation_results)
            warnings.extend(validation_warnings)
        
        success = len(failed) == 0
        
        return InstallationResult(
            success=success,
            installed_components=installed,
            failed_components=failed,
            warnings=warnings,
            paths_created=paths_created
        )
    
    def _create_directory_structure(self) -> List[Path]:
        """Create necessary directory structure"""
        dirs = [
            self.codex_home,
            self.prompts_dir,
            self.project_root / ".droidz",
            self.project_root / ".droidz" / "specs",
            self.project_root / ".droidz" / "specs" / "active",
            self.project_root / ".droidz" / "specs" / "archive",
            self.project_root / ".droidz" / "specs" / "templates",
            self.project_root / ".droidz" / "specs" / "examples",
        ]
        
        created = []
        for dir_path in dirs:
            if not self.dry_run and not dir_path.exists():
                dir_path.mkdir(parents=True, exist_ok=True)
                created.append(dir_path)
            elif self.dry_run:
                created.append(dir_path)
        
        return created
    
    def _install_commands(self, commands: List[Component]) -> Dict:
        """Install commands as Codex prompts"""
        installed = []
        failed = []
        warnings = []
        paths = []
        
        for component in commands:
            source_path = self.source_root / component.source_path
            
            if not source_path.exists():
                print(f"     ⚠️  Source not found: {component.name}")
                failed.append(component.name)
                warnings.append(f"Source file not found: {source_path}")
                continue
            
            # Convert
            result = self.converter.convert_command(source_path)
            
            if not result.success:
                print(f"     ❌ Failed: {component.name}")
                failed.append(component.name)
                warnings.extend(result.warnings)
                continue
            
            # Validate
            validation = self.validator.validate(result.content, component.name)
            if validation.has_errors:
                print(f"     ❌ Validation failed: {component.name}")
                failed.append(component.name)
                warnings.extend([f"{component.name}: {i.message}" for i in validation.issues])
                continue
            
            # Write to prompts directory
            output_path = self.prompts_dir / source_path.name
            
            if not self.dry_run:
                output_path.write_text(result.content)
            
            print(f"     • {source_path.name} → prompts/{source_path.name}")
            
            installed.append(component.name)
            paths.append(output_path)
            
            if result.warnings:
                warnings.extend([f"{component.name}: {w}" for w in result.warnings])
        
        return {
            'installed': installed,
            'failed': failed,
            'warnings': warnings,
            'paths': paths
        }
    
    def _install_agents(self, agents: List[Component]) -> Dict:
        """Install agents as Codex prompts"""
        installed = []
        failed = []
        warnings = []
        paths = []
        
        for component in agents:
            source_path = self.source_root / component.source_path
            
            if not source_path.exists():
                print(f"     ⚠️  Source not found: {component.name}")
                failed.append(component.name)
                warnings.append(f"Source file not found: {source_path}")
                continue
            
            # Convert
            result = self.converter.convert_agent(source_path)
            
            if not result.success:
                print(f"     ❌ Failed: {component.name}")
                failed.append(component.name)
                warnings.extend(result.warnings)
                continue
            
            # Write to prompts directory with cleaned name
            output_name = source_path.name.replace('droidz-', '')
            output_path = self.prompts_dir / output_name
            
            if not self.dry_run:
                output_path.write_text(result.content)
            
            print(f"     • {source_path.name} → prompts/{output_name}")
            
            installed.append(component.name)
            paths.append(output_path)
        
        return {
            'installed': installed,
            'failed': failed,
            'warnings': warnings,
            'paths': paths
        }
    
    def _create_agents_md(self, skills: List[Component]) -> Dict:
        """Create AGENTS.md with embedded skills"""
        try:
            # Build AGENTS.md content
            content_parts = [
                "# AGENTS.md - Project Instructions for Codex CLI",
                "",
                "This file contains development guidelines, best practices, and skills",
                "that Codex CLI will use when working on this project.",
                "",
                "## Tech Stack",
                "",
                "*(Add your project's tech stack here)*",
                "",
                "- Language: (e.g., TypeScript, Python)",
                "- Framework: (e.g., React, Next.js, Django)",
                "- Package Manager: (e.g., bun, npm, pnpm)",
                "",
                "## Development Guidelines",
                "",
                "### Code Style",
                "",
                "- Use consistent indentation",
                "- Follow project conventions",
                "- Add JSDoc/TSDoc for public APIs",
                "- Minimal comments (code should be self-documenting)",
                "",
                "### Testing Philosophy",
                "",
                "- Write tests alongside implementation",
                "- Test behavior, not implementation details",
                "- Aim for 80%+ code coverage",
                "",
                "### Git Workflow",
                "",
                "- Write descriptive commit messages",
                "- Keep commits atomic",
                "- Test before committing",
                "",
                "---",
                "",
                "## Droidz Skills (Embedded)",
                "",
                "The following skills are embedded from the Droidz framework:",
                "",
            ]
            
            # Add note about skills
            if skills:
                content_parts.append(f"Total Skills: {len(skills)}")
                content_parts.append("")
                content_parts.append("*(Skills will be embedded here in future versions)*")
            
            content = '\n'.join(content_parts)
            
            # Write to project root
            agents_md_path = self.project_root / "AGENTS.md"
            
            if not self.dry_run:
                agents_md_path.write_text(content)
            
            return {
                'success': True,
                'path': agents_md_path,
                'warnings': []
            }
            
        except Exception as e:
            return {
                'success': False,
                'path': None,
                'warnings': [f"Error creating AGENTS.md: {str(e)}"]
            }
    
    def _create_specs_system(self) -> Dict:
        """Create .droidz/specs/ directory structure"""
        try:
            base = self.project_root / ".droidz" / "specs"
            dirs = ['active', 'archive', 'templates', 'examples']
            paths = []
            
            for dir_name in dirs:
                dir_path = base / dir_name
                if not self.dry_run:
                    dir_path.mkdir(parents=True, exist_ok=True)
                paths.append(dir_path)
            
            # Create README in specs
            readme_content = """# Droidz Specifications

This directory contains feature specifications and implementation plans.

## Structure

- `active/` - Work-in-progress specs (not tracked in git)
- `archive/` - Completed specs (not tracked in git)
- `templates/` - Spec templates
- `examples/` - Reference examples

## Usage with Codex CLI

```
/prompts:build FEATURE="your feature" COMPLEXITY=medium
```

This will create a new spec in `active/`.
"""
            
            readme_path = base / "README.md"
            if not self.dry_run:
                readme_path.write_text(readme_content)
            paths.append(readme_path)
            
            return {
                'success': True,
                'paths': paths,
                'warnings': []
            }
            
        except Exception as e:
            return {
                'success': False,
                'paths': [],
                'warnings': [f"Error creating specs system: {str(e)}"]
            }
    
    def _process_validation_results(self, results: Dict) -> List[str]:
        """Process validation results and return warnings"""
        warnings = []
        
        for filename, result in results.items():
            if result.has_errors:
                warnings.append(f"{filename}: {result.error_count} validation errors")
            if result.has_warnings:
                warnings.append(f"{filename}: {result.warning_count} validation warnings")
        
        return warnings
    
    def print_summary(self, result: InstallationResult):
        """Print installation summary"""
        print("\n" + "━" * 60 + "\n")
        
        if result.success:
            print("✨ [bold green]Installation complete![/bold green]")
        else:
            print("⚠️  [bold yellow]Installation completed with issues[/bold yellow]")
        
        print()
        print(f"  Installed: {len(result.installed_components)} components")
        print(f"  Failed: {len(result.failed_components)} components")
        print(f"  Warnings: {len(result.warnings)}")
        print()
        
        if result.installed_components:
            print("  ✓ Successfully installed:")
            for comp in result.installed_components:
                print(f"    • {comp}")
            print()
        
        if result.failed_components:
            print("  ✗ Failed to install:")
            for comp in result.failed_components:
                print(f"    • {comp}")
            print()
        
        if result.warnings:
            print("  ⚠️  Warnings:")
            for warning in result.warnings[:5]:  # Show first 5
                print(f"    • {warning}")
            if len(result.warnings) > 5:
                print(f"    ... and {len(result.warnings) - 5} more")
            print()
        
        print("📖 Quick Start:")
        print()
        print("  # Start Codex CLI")
        print("  codex")
        print()
        print("  # Try commands:")
        print('  /prompts:build FEATURE="user auth" COMPLEXITY=high')
        print("  /prompts:validate")
        print('  /prompts:codegen FEATURE="login form"')
        print()
        print("📚 Documentation:")
        print("  • Codex Guide: docs/CODEX_CLI.md")
        print("  • Migration: docs/CODEX_MIGRATION.md")
        print("  • Compatibility: docs/CODEX_COMPATIBILITY_BREAKDOWN.md")
        print()
