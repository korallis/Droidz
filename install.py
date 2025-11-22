#!/usr/bin/env python3
"""
Droidz v4.0 Installer
Interactive Python installer for Claude Code, Codex CLI, and Droid CLI (Factory.ai)

Usage:
    python3 install.py
    python3 install.py --help
"""

import sys
import os

# Ensure we're running Python 3.7+
if sys.version_info < (3, 7):
    print("❌ Droidz installer requires Python 3.7 or higher")
    print(f"   You're running Python {sys.version_info.major}.{sys.version_info.minor}")
    sys.exit(1)

# Add installer directory to path
sys.path.insert(0, os.path.dirname(__file__))

from installer.cli import main

if __name__ == "__main__":
    main()
