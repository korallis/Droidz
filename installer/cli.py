"""
Interactive CLI for Droidz installer using inquirer
"""

import sys
from typing import List, Dict, Optional
from rich.console import Console
from rich.panel import Panel
from rich.table import Table
from rich.progress import Progress, SpinnerColumn, TextColumn
from rich import print as rprint

try:
    import inquirer
    from inquirer.themes import GreenPassion
except ImportError:
    print("❌ Missing dependencies. Installing...")
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "-q", "inquirer"])
    import inquirer
    from inquirer.themes import GreenPassion

from .compatibility import DependencyManager, Platform, PlatformStatus
from .components import ComponentRegistry, Component, CompatibilityLevel


console = Console()


class InstallerCLI:
    """Interactive CLI for Droidz installation"""
    
    def __init__(self):
        self.deps = DependencyManager()
        self.registry = ComponentRegistry()
        self.selected_platform: Optional[str] = None
        self.selected_components: List[Component] = []
        
    def show_welcome(self):
        """Show welcome banner"""
        console.clear()
        
        welcome_text = """
╔═══════════════════════════════════════════════════╗
║                                                   ║
║           🤖 Droidz v4.0 Installer                ║
║                                                   ║
║   Production-grade AI development framework       ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
        """
        
        console.print(welcome_text, style="bold cyan")
        console.print()
    
    def detect_environment(self) -> Dict:
        """Detect and display environment"""
        console.print("\n🔍 [bold]Detecting environment...[/bold]\n")
        
        with Progress(
            SpinnerColumn(),
            TextColumn("[progress.description]{task.description}"),
            console=console,
        ) as progress:
            task = progress.add_task("[cyan]Scanning system...", total=None)
            
            # Get system info
            system_info = self.deps.get_system_info()
            deps = self.deps.check_all_dependencies()
            platforms = self.deps.detect_available_platforms()
            
            progress.update(task, completed=True)
        
        # Create results table
        table = Table(show_header=True, header_style="bold magenta")
        table.add_column("Component", style="cyan", width=20)
        table.add_column("Status", width=12)
        table.add_column("Details", style="dim")
        
        # OS Info
        table.add_row(
            "OS",
            "✓ Detected",
            f"{system_info['os']} ({system_info['shell']})"
        )
        
        # Python
        python = deps['python']
        table.add_row(
            "Python",
            "[green]✓ Installed[/green]" if python.installed else "[red]✗ Missing[/red]",
            python.version or "unknown"
        )
        
        # Git
        git = deps['git']
        table.add_row(
            "Git",
            "[green]✓ Installed[/green]" if git.installed else "[yellow]⚠ Missing[/yellow]",
            git.version or "not found"
        )
        
        # Node.js
        node = deps['node']
        node_status = "[green]✓ Installed[/green]" if node.installed else "[yellow]⚠ Missing[/yellow]"
        if node.installed:
            node_valid, node_issue = self.deps.verify_node_version()
            if not node_valid:
                node_status = f"[yellow]⚠ {node_issue}[/yellow]"
        
        table.add_row(
            "Node.js",
            node_status,
            node.version or "not found (required for Codex CLI)"
        )
        
        # Platforms
        table.add_row("", "", "")  # Separator
        
        for platform, status in platforms.items():
            if platform == Platform.UNKNOWN:
                continue
                
            status_text = "[green]✓ Installed[/green]" if status.installed else "[dim]Not found[/dim]"
            details = status.version or "not installed"
            
            table.add_row(
                platform.value.replace("-", " ").title(),
                status_text,
                details
            )
        
        console.print(table)
        console.print()
        
        return {
            'system_info': system_info,
            'deps': deps,
            'platforms': platforms
        }
    
    def select_platform(self, platforms: Dict[Platform, PlatformStatus]) -> Optional[str]:
        """Let user select target platform"""
        console.print("\n" + "─" * 60 + "\n")
        
        # Build choices based on what's installed
        choices = []
        
        if platforms[Platform.CLAUDE_CODE].installed:
            choices.append(("Claude Code (installed ✓)", "claude-code"))
        else:
            choices.append(("Claude Code (not installed)", "claude-code"))
        
        if platforms[Platform.CODEX_CLI].installed:
            choices.append(("Codex CLI (installed ✓)", "codex-cli"))
        else:
            choices.append(("Codex CLI (not installed)", "codex-cli"))
        
        if platforms[Platform.DROID_CLI].installed:
            choices.append(("Droid CLI - Factory.ai (installed ✓)", "droid-cli"))
        else:
            choices.append(("Droid CLI - Factory.ai (not installed)", "droid-cli"))
        
        choices.append(("Install for all platforms", "all"))
        choices.append(("Exit", "exit"))
        
        questions = [
            inquirer.List('platform',
                         message="Select installation target",
                         choices=choices,
                         carousel=True)
        ]
        
        answers = inquirer.prompt(questions, theme=GreenPassion())
        
        if not answers or answers['platform'] == 'exit':
            return None
        
        return answers['platform']
    
    def select_components(self, platform: str) -> List[Component]:
        """Let user select components to install"""
        console.print("\n" + "─" * 60 + "\n")
        
        # Get compatible components
        compatible = self.registry.get_compatible_for_platform(platform)
        
        # Build choices with compatibility indicators
        choices = []
        
        for component in compatible:
            # Get compatibility level
            if platform == "claude-code":
                compat = component.claude_compatible
            elif platform == "codex-cli":
                compat = component.codex_compatible
            else:
                compat = component.droid_compatible
            
            # Build choice string
            if compat == CompatibilityLevel.FULL:
                indicator = "✅"
            elif compat == CompatibilityLevel.ADAPTED:
                indicator = "⚠️"
            elif compat == CompatibilityLevel.LIMITED:
                indicator = "⚠️"
            else:
                indicator = "❌"
            
            choice_text = f"{indicator} {component.name} - {component.description}"
            
            if compat == CompatibilityLevel.ADAPTED:
                choice_text += " (will adapt)"
            elif compat == CompatibilityLevel.LIMITED:
                choice_text += " (limited)"
            
            # Add to choices with component reference
            choices.append((choice_text, component))
        
        # Add option to select all defaults
        choices.insert(0, (("✓ Select all recommended components", "all-defaults")))
        
        questions = [
            inquirer.Checkbox('components',
                            message="Select components to install (Space to toggle, Enter to confirm)",
                            choices=choices,
                            default=[c for c in compatible if c.default_enabled])
        ]
        
        answers = inquirer.prompt(questions, theme=GreenPassion())
        
        if not answers:
            return []
        
        selected = answers['components']
        
        # Handle "all-defaults" special case
        if "all-defaults" in selected:
            return self.registry.get_default_enabled()
        
        # Filter out string markers and return only Component objects
        return [c for c in selected if isinstance(c, Component)]
    
    def show_installation_plan(self, platform: str, components: List[Component]):
        """Show installation plan before proceeding"""
        console.print("\n" + "─" * 60 + "\n")
        console.print("[bold]📋 Installation Plan[/bold]\n")
        
        # Platform info
        console.print(f"[cyan]Target Platform:[/cyan] {platform}")
        console.print(f"[cyan]Components:[/cyan] {len(components)}")
        console.print()
        
        # Component breakdown by type
        by_type = {}
        for comp in components:
            type_name = comp.type.value
            if type_name not in by_type:
                by_type[type_name] = []
            by_type[type_name].append(comp)
        
        for type_name, comps in sorted(by_type.items()):
            console.print(f"  [bold]{type_name.title()}:[/bold] {len(comps)}")
            for comp in comps:
                console.print(f"    • {comp.name}")
        
        console.print()
        
        # Confirm
        questions = [
            inquirer.Confirm('proceed',
                           message="Proceed with installation?",
                           default=True)
        ]
        
        answers = inquirer.prompt(questions, theme=GreenPassion())
        
        return answers and answers['proceed']
    
    def run(self):
        """Run the interactive installer"""
        self.show_welcome()
        
        # Detect environment
        env_info = self.detect_environment()
        
        # Select platform
        platform = self.select_platform(env_info['platforms'])
        
        if not platform:
            console.print("\n[yellow]Installation cancelled.[/yellow]")
            return False
        
        self.selected_platform = platform
        
        # Select components
        components = self.select_components(platform)
        
        if not components:
            console.print("\n[yellow]No components selected. Installation cancelled.[/yellow]")
            return False
        
        self.selected_components = components
        
        # Show plan and confirm
        if not self.show_installation_plan(platform, components):
            console.print("\n[yellow]Installation cancelled.[/yellow]")
            return False
        
        # Return the configuration for actual installation
        return {
            'platform': platform,
            'components': components,
            'env_info': env_info
        }


def main():
    """Main entry point for CLI"""
    try:
        cli = InstallerCLI()
        result = cli.run()
        
        if result:
            console.print("\n[green]✨ Configuration complete![/green]")
            console.print("\n[dim]Installation will proceed with selected components...[/dim]")
            return result
        else:
            sys.exit(0)
            
    except KeyboardInterrupt:
        console.print("\n\n[yellow]Installation interrupted by user.[/yellow]")
        sys.exit(1)
    except Exception as e:
        console.print(f"\n[red]❌ Error: {str(e)}[/red]")
        import traceback
        console.print(f"[dim]{traceback.format_exc()}[/dim]")
        sys.exit(1)


if __name__ == "__main__":
    main()
