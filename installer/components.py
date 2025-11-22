"""
Component registry and metadata for Droidz installer
"""

from enum import Enum
from dataclasses import dataclass
from typing import List, Optional


class ComponentType(Enum):
    """Types of components"""
    COMMAND = "command"
    AGENT = "agent"
    SKILL = "skill"
    VALIDATION = "validation"
    SPEC = "spec"
    HOOK = "hook"
    CONFIG = "config"


class CompatibilityLevel(Enum):
    """Compatibility levels for components"""
    FULL = "full"           # Works identically
    ADAPTED = "adapted"     # Works with conversion
    LIMITED = "limited"     # Works with limitations
    UNSUPPORTED = "unsupported"  # Doesn't work


@dataclass
class Component:
    """A Droidz component"""
    id: str
    name: str
    type: ComponentType
    description: str
    
    # File paths
    source_path: str  # Path in .claude or .factory
    
    # Compatibility
    claude_compatible: CompatibilityLevel = CompatibilityLevel.FULL
    codex_compatible: CompatibilityLevel = CompatibilityLevel.FULL
    droid_compatible: CompatibilityLevel = CompatibilityLevel.FULL
    
    # Metadata
    required: bool = False
    default_enabled: bool = True
    size_kb: int = 0
    
    # Conversion notes
    codex_notes: Optional[str] = None
    
    def is_compatible_with(self, platform: str) -> bool:
        """Check if component is compatible with platform"""
        if platform == "claude-code":
            return self.claude_compatible != CompatibilityLevel.UNSUPPORTED
        elif platform == "codex-cli":
            return self.codex_compatible != CompatibilityLevel.UNSUPPORTED
        elif platform == "droid-cli":
            return self.droid_compatible != CompatibilityLevel.UNSUPPORTED
        return False


class ComponentRegistry:
    """Registry of all Droidz components"""
    
    def __init__(self):
        self.components = self._initialize_components()
    
    def _initialize_components(self) -> List[Component]:
        """Initialize the component registry"""
        components = []
        
        # ============================================================================
        # COMMANDS
        # ============================================================================
        
        commands = [
            Component(
                id="cmd-build",
                name="/build",
                type=ComponentType.COMMAND,
                description="Generate feature specifications",
                source_path=".claude/commands/build.md",
                claude_compatible=CompatibilityLevel.FULL,
                codex_compatible=CompatibilityLevel.ADAPTED,
                droid_compatible=CompatibilityLevel.FULL,
                required=True,
                default_enabled=True,
                codex_notes="Convert to /prompts:build with descriptive workflow"
            ),
            Component(
                id="cmd-validate",
                name="/validate",
                type=ComponentType.COMMAND,
                description="Run validation pipeline (5 phases)",
                source_path=".claude/commands/validate.md",
                claude_compatible=CompatibilityLevel.FULL,
                codex_compatible=CompatibilityLevel.ADAPTED,
                droid_compatible=CompatibilityLevel.FULL,
                required=True,
                default_enabled=True,
                codex_notes="Convert shell commands to instructions"
            ),
            Component(
                id="cmd-validate-init",
                name="/validate-init",
                type=ComponentType.COMMAND,
                description="Initialize validation workflow",
                source_path=".claude/commands/validate-init.md",
                claude_compatible=CompatibilityLevel.FULL,
                codex_compatible=CompatibilityLevel.ADAPTED,
                droid_compatible=CompatibilityLevel.FULL,
                required=False,
                default_enabled=True,
                codex_notes="Convert to descriptive tool detection"
            ),
            Component(
                id="cmd-parallel",
                name="/parallel",
                type=ComponentType.COMMAND,
                description="Execute tasks in parallel",
                source_path=".claude/commands/parallel.md",
                claude_compatible=CompatibilityLevel.FULL,
                codex_compatible=CompatibilityLevel.LIMITED,
                droid_compatible=CompatibilityLevel.FULL,
                required=False,
                default_enabled=True,
                codex_notes="Sequential execution only (no parallel spawn)"
            ),
            Component(
                id="cmd-init",
                name="/init",
                type=ComponentType.COMMAND,
                description="Initialize project for Droidz",
                source_path=".claude/commands/init.md",
                claude_compatible=CompatibilityLevel.FULL,
                codex_compatible=CompatibilityLevel.FULL,
                droid_compatible=CompatibilityLevel.FULL,
                required=False,
                default_enabled=True,
                codex_notes="Fully compatible"
            ),
        ]
        
        components.extend(commands)
        
        # ============================================================================
        # AGENTS / DROIDS
        # ============================================================================
        
        agents = [
            Component(
                id="agent-orchestrator",
                name="Orchestrator",
                type=ComponentType.AGENT,
                description="Coordinates parallel work streams",
                source_path=".factory/droids/droidz-orchestrator.md",
                claude_compatible=CompatibilityLevel.FULL,
                codex_compatible=CompatibilityLevel.ADAPTED,
                droid_compatible=CompatibilityLevel.FULL,
                required=True,
                default_enabled=True,
                codex_notes="Sequential workflow, no parallel spawn"
            ),
            Component(
                id="agent-codegen",
                name="Code Generator",
                type=ComponentType.AGENT,
                description="Implements features with tests",
                source_path=".factory/droids/droidz-codegen.md",
                claude_compatible=CompatibilityLevel.FULL,
                codex_compatible=CompatibilityLevel.FULL,
                droid_compatible=CompatibilityLevel.FULL,
                required=True,
                default_enabled=True,
                codex_notes="Fully compatible"
            ),
            Component(
                id="agent-test",
                name="Test Specialist",
                type=ComponentType.AGENT,
                description="Writes and fixes tests",
                source_path=".factory/droids/droidz-test.md",
                claude_compatible=CompatibilityLevel.FULL,
                codex_compatible=CompatibilityLevel.FULL,
                droid_compatible=CompatibilityLevel.FULL,
                required=True,
                default_enabled=True,
                codex_notes="Fully compatible"
            ),
            Component(
                id="agent-refactor",
                name="Refactor Specialist",
                type=ComponentType.AGENT,
                description="Code quality improvements",
                source_path=".factory/droids/droidz-refactor.md",
                claude_compatible=CompatibilityLevel.FULL,
                codex_compatible=CompatibilityLevel.FULL,
                droid_compatible=CompatibilityLevel.FULL,
                required=False,
                default_enabled=True,
                codex_notes="Fully compatible"
            ),
            Component(
                id="agent-ui-designer",
                name="UI Designer",
                type=ComponentType.AGENT,
                description="Frontend UI components",
                source_path=".factory/droids/droidz-ui-designer.md",
                claude_compatible=CompatibilityLevel.FULL,
                codex_compatible=CompatibilityLevel.FULL,
                droid_compatible=CompatibilityLevel.FULL,
                required=False,
                default_enabled=True,
                codex_notes="Fully compatible"
            ),
            Component(
                id="agent-ux-designer",
                name="UX Designer",
                type=ComponentType.AGENT,
                description="User experience flows",
                source_path=".factory/droids/droidz-ux-designer.md",
                claude_compatible=CompatibilityLevel.FULL,
                codex_compatible=CompatibilityLevel.FULL,
                droid_compatible=CompatibilityLevel.FULL,
                required=False,
                default_enabled=False,
                codex_notes="Fully compatible"
            ),
        ]
        
        components.extend(agents)
        
        # ============================================================================
        # VALIDATION
        # ============================================================================
        
        validation = [
            Component(
                id="validation-pipeline",
                name="Validation Pipeline",
                type=ComponentType.VALIDATION,
                description="5-phase validation system",
                source_path=".factory/commands/validate.md",
                claude_compatible=CompatibilityLevel.FULL,
                codex_compatible=CompatibilityLevel.ADAPTED,
                droid_compatible=CompatibilityLevel.FULL,
                required=True,
                default_enabled=True,
                codex_notes="Convert to descriptive workflow"
            ),
        ]
        
        components.extend(validation)
        
        # ============================================================================
        # SPECS SYSTEM
        # ============================================================================
        
        specs = [
            Component(
                id="specs-system",
                name="Specs System",
                type=ComponentType.SPEC,
                description=".droidz/specs/ directory structure",
                source_path=".droidz/specs/",
                claude_compatible=CompatibilityLevel.FULL,
                codex_compatible=CompatibilityLevel.FULL,
                droid_compatible=CompatibilityLevel.FULL,
                required=True,
                default_enabled=True,
                codex_notes="Fully compatible (file system)"
            ),
        ]
        
        components.extend(specs)
        
        return components
    
    def get_by_type(self, component_type: ComponentType) -> List[Component]:
        """Get all components of a specific type"""
        return [c for c in self.components if c.type == component_type]
    
    def get_by_id(self, component_id: str) -> Optional[Component]:
        """Get a component by ID"""
        for c in self.components:
            if c.id == component_id:
                return c
        return None
    
    def get_compatible_for_platform(self, platform: str) -> List[Component]:
        """Get all components compatible with a platform"""
        return [c for c in self.components if c.is_compatible_with(platform)]
    
    def get_default_enabled(self) -> List[Component]:
        """Get all components that are enabled by default"""
        return [c for c in self.components if c.default_enabled]
    
    def get_required(self) -> List[Component]:
        """Get all required components"""
        return [c for c in self.components if c.required]
