"""
Platform and dependency detection for Droidz installer
"""

import os
import sys
import shutil
import subprocess
from enum import Enum
from typing import Optional, Dict, List
from dataclasses import dataclass


class Platform(Enum):
    """Supported AI CLI platforms"""
    CLAUDE_CODE = "claude-code"
    CODEX_CLI = "codex-cli"
    DROID_CLI = "droid-cli"
    UNKNOWN = "unknown"


class OS(Enum):
    """Operating systems"""
    MACOS = "macos"
    LINUX = "linux"
    WSL2 = "wsl2"
    WINDOWS = "windows"
    UNKNOWN = "unknown"


@dataclass
class DependencyStatus:
    """Status of a dependency"""
    name: str
    installed: bool
    version: Optional[str] = None
    path: Optional[str] = None
    required: bool = True


@dataclass
class PlatformStatus:
    """Status of an AI CLI platform"""
    platform: Platform
    installed: bool
    version: Optional[str] = None
    path: Optional[str] = None
    compatible: bool = True
    issues: List[str] = None

    def __post_init__(self):
        if self.issues is None:
            self.issues = []


class DependencyManager:
    """Manages platform detection and dependency checking"""
    
    def __init__(self):
        self.os = self._detect_os()
        self.shell = self._detect_shell()
        self.home = os.path.expanduser("~")
        
    def _detect_os(self) -> OS:
        """Detect the operating system"""
        if sys.platform == "darwin":
            return OS.MACOS
        elif sys.platform == "win32":
            return OS.WINDOWS
        elif sys.platform.startswith("linux"):
            # Check if we're in WSL2
            if os.path.exists("/proc/version"):
                with open("/proc/version", "r") as f:
                    if "microsoft" in f.read().lower():
                        return OS.WSL2
            return OS.LINUX
        return OS.UNKNOWN
    
    def _detect_shell(self) -> str:
        """Detect the current shell"""
        shell = os.environ.get("SHELL", "")
        if shell:
            return os.path.basename(shell)
        return "unknown"
    
    def _get_command_version(self, command: str, version_flag: str = "--version") -> Optional[str]:
        """Get version of a command"""
        try:
            result = subprocess.run(
                [command, version_flag],
                capture_output=True,
                text=True,
                timeout=5
            )
            if result.returncode == 0:
                # Extract version from output (first line usually)
                output = result.stdout.strip().split('\n')[0]
                return output
            return None
        except (subprocess.TimeoutExpired, FileNotFoundError, Exception):
            return None
    
    def check_codex_installation(self) -> DependencyStatus:
        """Check if Codex CLI is installed"""
        path = shutil.which("codex")
        installed = path is not None
        version = None
        
        if installed:
            version = self._get_command_version("codex", "--version")
        
        return DependencyStatus(
            name="Codex CLI",
            installed=installed,
            version=version,
            path=path,
            required=False
        )
    
    def check_claude_installation(self) -> DependencyStatus:
        """Check if Claude Code is installed"""
        path = shutil.which("claude")
        installed = path is not None
        version = None
        
        if installed:
            version = self._get_command_version("claude", "--version")
        
        return DependencyStatus(
            name="Claude Code",
            installed=installed,
            version=version,
            path=path,
            required=False
        )
    
    def check_droid_installation(self) -> DependencyStatus:
        """Check if Droid CLI (Factory.ai) is installed"""
        # Droid CLI doesn't have a standalone command; it runs through Factory.ai
        # Check for Factory.ai CLI instead
        path = shutil.which("factory")
        installed = path is not None
        version = None
        
        if installed:
            version = self._get_command_version("factory", "--version")
        
        return DependencyStatus(
            name="Droid CLI (Factory.ai)",
            installed=installed,
            version=version,
            path=path,
            required=False
        )
    
    def check_node_installation(self) -> DependencyStatus:
        """Check if Node.js is installed"""
        path = shutil.which("node")
        installed = path is not None
        version = None
        
        if installed:
            version = self._get_command_version("node", "--version")
        
        return DependencyStatus(
            name="Node.js",
            installed=installed,
            version=version,
            path=path,
            required=True  # Required for Codex CLI
        )
    
    def check_python_installation(self) -> DependencyStatus:
        """Check Python installation"""
        return DependencyStatus(
            name="Python",
            installed=True,  # We're running Python!
            version=f"{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}",
            path=sys.executable,
            required=True
        )
    
    def check_git_installation(self) -> DependencyStatus:
        """Check if git is installed"""
        path = shutil.which("git")
        installed = path is not None
        version = None
        
        if installed:
            version = self._get_command_version("git", "--version")
        
        return DependencyStatus(
            name="Git",
            installed=installed,
            version=version,
            path=path,
            required=True
        )
    
    def detect_available_platforms(self) -> Dict[Platform, PlatformStatus]:
        """Detect which AI CLI platforms are installed"""
        platforms = {}
        
        # Check Codex CLI
        codex = self.check_codex_installation()
        platforms[Platform.CODEX_CLI] = PlatformStatus(
            platform=Platform.CODEX_CLI,
            installed=codex.installed,
            version=codex.version,
            path=codex.path,
            compatible=True
        )
        
        # Check Claude Code
        claude = self.check_claude_installation()
        platforms[Platform.CLAUDE_CODE] = PlatformStatus(
            platform=Platform.CLAUDE_CODE,
            installed=claude.installed,
            version=claude.version,
            path=claude.path,
            compatible=True
        )
        
        # Check Droid CLI
        droid = self.check_droid_installation()
        platforms[Platform.DROID_CLI] = PlatformStatus(
            platform=Platform.DROID_CLI,
            installed=droid.installed,
            version=droid.version,
            path=droid.path,
            compatible=True
        )
        
        return platforms
    
    def check_all_dependencies(self) -> Dict[str, DependencyStatus]:
        """Check all dependencies"""
        deps = {}
        
        deps['python'] = self.check_python_installation()
        deps['git'] = self.check_git_installation()
        deps['node'] = self.check_node_installation()
        deps['codex'] = self.check_codex_installation()
        deps['claude'] = self.check_claude_installation()
        deps['droid'] = self.check_droid_installation()
        
        return deps
    
    def verify_node_version(self) -> tuple[bool, Optional[str]]:
        """Verify Node.js version meets minimum requirements"""
        node = self.check_node_installation()
        
        if not node.installed:
            return False, "Node.js not installed"
        
        if not node.version:
            return False, "Could not determine Node.js version"
        
        try:
            # Extract version number (e.g., "v20.10.0" -> "20.10.0")
            version_str = node.version.lstrip('v').split()[0]
            major = int(version_str.split('.')[0])
            
            # Require Node.js 18+ for Codex CLI
            if major < 18:
                return False, f"Node.js {major} is too old (require 18+)"
            
            return True, None
        except (ValueError, IndexError):
            return False, "Could not parse Node.js version"
    
    def get_codex_home(self) -> str:
        """Get CODEX_HOME directory"""
        return os.environ.get("CODEX_HOME", os.path.join(self.home, ".codex"))
    
    def get_claude_home(self) -> str:
        """Get Claude Code home directory"""
        return os.path.join(self.home, ".claude")
    
    def get_factory_home(self) -> str:
        """Get Factory.ai home directory"""
        return os.path.join(os.getcwd(), ".factory")
    
    def is_git_repository(self) -> bool:
        """Check if current directory is a git repository"""
        return os.path.isdir(".git")
    
    def get_system_info(self) -> Dict[str, str]:
        """Get comprehensive system information"""
        return {
            "os": self.os.value,
            "shell": self.shell,
            "python_version": sys.version.split()[0],
            "home": self.home,
            "cwd": os.getcwd(),
            "is_git_repo": str(self.is_git_repository())
        }
