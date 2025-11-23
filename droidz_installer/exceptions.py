"""Custom exception types for the Droidz installer."""


class InstallerError(Exception):
    """Raised when the installer encounters a recoverable error."""


__all__ = ["InstallerError"]
