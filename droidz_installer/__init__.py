"""Droidz installer package."""

from .core import InstallOptions, install, list_platforms
from .exceptions import InstallerError

__all__ = ["InstallOptions", "InstallerError", "install", "list_platforms"]

__version__ = "4.11.1"
