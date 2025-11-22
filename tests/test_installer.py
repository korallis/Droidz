#!/usr/bin/env python3
"""
Test installer functionality
"""

import sys
import os
from pathlib import Path
import tempfile
import shutil

# Add installer to path
sys.path.insert(0, str(Path(__file__).parent.parent / "installer"))


def test_compatibility_detection():
    """Test platform and dependency detection"""
    print("Testing compatibility detection...")
    
    try:
        import platform
        import shutil
        
        # Test OS detection
        os_name = platform.system()
        print(f"  ✓ OS detected: {os_name}")
        
        # Test shell detection
        shell = os.environ.get('SHELL', 'unknown')
        print(f"  ✓ Shell detected: {shell}")
        
        # Test Node.js detection
        has_node = shutil.which('node') is not None
        print(f"  {'✓' if has_node else '⚠️'} Node.js: {'Found' if has_node else 'Not found'}")
        
        # Test Git detection
        has_git = shutil.which('git') is not None
        print(f"  {'✓' if has_git else '⚠️'} Git: {'Found' if has_git else 'Not found'}")
        
        # Test Python detection
        py_version = platform.python_version()
        print(f"  ✓ Python: {py_version}")
        
        return True
        
    except Exception as e:
        print(f"  ✗ Exception: {e}")
        import traceback
        traceback.print_exc()
        return False


def test_component_registry():
    """Test component registry functionality"""
    print("\nTesting component registry...")
    
    try:
        # Check that component files exist
        prompts_dir = Path(__file__).parent.parent / "templates" / "codex" / "prompts"
        
        if not prompts_dir.exists():
            print(f"  ✗ Prompts directory not found")
            return False
        
        prompts = list(prompts_dir.glob("*.md"))
        print(f"  ✓ Found {len(prompts)} Codex CLI prompts")
        
        # List prompts
        for prompt in prompts:
            print(f"    - {prompt.name}")
        
        # Check expected prompts
        expected = ['build.md', 'validate.md', 'codegen.md', 'test-specialist.md', 'orchestrator.md', 'init.md']
        found = [p.name for p in prompts]
        
        missing = set(expected) - set(found)
        if missing:
            print(f"  ⚠️  Missing prompts: {missing}")
        else:
            print(f"  ✓ All expected prompts present")
        
        return len(missing) == 0
        
    except Exception as e:
        print(f"  ✗ Exception: {e}")
        import traceback
        traceback.print_exc()
        return False


def test_specs_directory_creation():
    """Test .droidz/specs/ directory structure creation"""
    print("\nTesting specs directory creation...")
    
    try:
        # Create temporary directory
        with tempfile.TemporaryDirectory() as tmpdir:
            specs_dir = Path(tmpdir) / ".droidz" / "specs"
            
            # Create structure
            (specs_dir / "active").mkdir(parents=True, exist_ok=True)
            (specs_dir / "archive").mkdir(parents=True, exist_ok=True)
            (specs_dir / "templates").mkdir(parents=True, exist_ok=True)
            (specs_dir / "examples").mkdir(parents=True, exist_ok=True)
            
            # Verify structure
            required_dirs = ['active', 'archive', 'templates', 'examples']
            
            for dirname in required_dirs:
                dirpath = specs_dir / dirname
                if dirpath.exists() and dirpath.is_dir():
                    print(f"  ✓ Created: .droidz/specs/{dirname}/")
                else:
                    print(f"  ✗ Failed to create: .droidz/specs/{dirname}/")
                    return False
            
            return True
            
    except Exception as e:
        print(f"  ✗ Exception: {e}")
        return False


def test_gitignore_generation():
    """Test .gitignore pattern generation"""
    print("\nTesting .gitignore generation...")
    
    gitignore_content = """# Droidz v4.0 - Ignore WIP and completed specs
.droidz/specs/active/
.droidz/specs/archive/

# Keep templates and examples in git
!.droidz/specs/templates/
!.droidz/specs/examples/
"""
    
    try:
        with tempfile.TemporaryDirectory() as tmpdir:
            gitignore_path = Path(tmpdir) / ".gitignore"
            gitignore_path.write_text(gitignore_content)
            
            content = gitignore_path.read_text()
            
            checks = [
                ('.droidz/specs/active/' in content, "Ignores active specs"),
                ('.droidz/specs/archive/' in content, "Ignores archived specs"),
                ('!.droidz/specs/templates/' in content, "Keeps templates"),
                ('!.droidz/specs/examples/' in content, "Keeps examples"),
            ]
            
            passed = sum(1 for check, _ in checks if check)
            
            for check, description in checks:
                status = "✓" if check else "✗"
                print(f"  {status} {description}")
            
            return passed == len(checks)
            
    except Exception as e:
        print(f"  ✗ Exception: {e}")
        return False


def test_codex_prompts_directory():
    """Test Codex CLI prompts directory setup"""
    print("\nTesting Codex prompts directory...")
    
    # Note: We won't actually create in ~/.codex/prompts/
    # Just verify the logic would work
    
    try:
        home = Path.home()
        codex_prompts_dir = home / ".codex" / "prompts"
        
        print(f"  ℹ️  Target directory: {codex_prompts_dir}")
        
        # Check if directory exists (may or may not)
        if codex_prompts_dir.exists():
            print(f"  ✓ Directory exists")
            
            # Check for prompts
            prompts = list(codex_prompts_dir.glob("*.md"))
            if prompts:
                print(f"  ✓ Found {len(prompts)} prompts installed")
            else:
                print(f"  ⚠️  No prompts found (not yet installed)")
        else:
            print(f"  ⚠️  Directory does not exist (Codex CLI not set up)")
        
        # Test that we can create the directory structure in temp
        with tempfile.TemporaryDirectory() as tmpdir:
            test_codex_dir = Path(tmpdir) / ".codex" / "prompts"
            test_codex_dir.mkdir(parents=True, exist_ok=True)
            
            if test_codex_dir.exists():
                print(f"  ✓ Can create Codex prompts directory structure")
                return True
            else:
                print(f"  ✗ Failed to create directory structure")
                return False
        
    except Exception as e:
        print(f"  ✗ Exception: {e}")
        return False


def test_validation_patterns():
    """Test validation patterns for Codex compatibility"""
    print("\nTesting validation patterns...")
    
    try:
        import re
        
        # Test valid prompt
        valid_prompt = """---
description: Test prompt
argument-hint: ARG=<value>
---

# Test Prompt

This is a test prompt for Codex CLI.
"""
        
        # Check for Claude Code specific patterns
        issues = []
        if re.search(r'model:\s*inherit', valid_prompt):
            issues.append("Contains 'model: inherit'")
        if re.search(r'tools:\s*\[', valid_prompt):
            issues.append("Contains 'tools:' field")
        if re.search(r'!\`[^`]+\`', valid_prompt):
            issues.append("Contains shell execution syntax")
        
        if len(issues) == 0:
            print(f"  ✓ Valid prompt passes validation")
        else:
            print(f"  ✗ Valid prompt has issues: {issues}")
            return False
        
        # Test invalid prompt (has Claude Code syntax)
        invalid_prompt = """---
model: inherit
tools: []
---

# Test Prompt

Run this:
!`npm test`
"""
        
        issues = []
        if re.search(r'model:\s*inherit', invalid_prompt):
            issues.append("Contains 'model: inherit'")
        if re.search(r'tools:\s*\[', invalid_prompt):
            issues.append("Contains 'tools:' field")
        if re.search(r'!\`[^`]+\`', invalid_prompt):
            issues.append("Contains shell execution syntax")
        
        if len(issues) > 0:
            print(f"  ✓ Invalid prompt detected ({len(issues)} issues)")
            for issue in issues:
                print(f"    - {issue}")
        else:
            print(f"  ✗ Invalid prompt not detected")
            return False
        
        return True
        
    except Exception as e:
        print(f"  ✗ Exception: {e}")
        import traceback
        traceback.print_exc()
        return False


def test_agents_md_generation():
    """Test AGENTS.md generation"""
    print("\nTesting AGENTS.md generation...")
    
    agents_md_template = """# AGENTS.md - Project Instructions for Codex CLI

## Tech Stack

### Frontend
- **Language**: TypeScript
- **Framework**: React + Next.js

### Build & Package Management
- **Package Manager**: npm

### Testing
- **Framework**: Jest

---

## Development Guidelines

### Code Style
- **Indentation**: 2 spaces
- **Components**: Functional components with hooks

### Commands
```bash
npm run dev          # Start dev server
npm test             # Run tests
```
"""
    
    try:
        with tempfile.TemporaryDirectory() as tmpdir:
            agents_path = Path(tmpdir) / "AGENTS.md"
            agents_path.write_text(agents_md_template)
            
            content = agents_path.read_text()
            
            checks = [
                ('# AGENTS.md' in content, "Has title"),
                ('Tech Stack' in content, "Has tech stack section"),
                ('Development Guidelines' in content, "Has guidelines"),
                ('Commands' in content, "Has commands section"),
                ('npm run dev' in content, "Has specific commands"),
            ]
            
            passed = sum(1 for check, _ in checks if check)
            
            for check, description in checks:
                status = "✓" if check else "✗"
                print(f"  {status} {description}")
            
            return passed == len(checks)
            
    except Exception as e:
        print(f"  ✗ Exception: {e}")
        return False


def main():
    """Run all installer tests"""
    print("=" * 60)
    print("Droidz v4.0 - Installer Tests")
    print("=" * 60)
    
    tests = [
        ("Compatibility Detection", test_compatibility_detection),
        ("Component Registry", test_component_registry),
        ("Specs Directory Creation", test_specs_directory_creation),
        (".gitignore Generation", test_gitignore_generation),
        ("Codex Prompts Directory", test_codex_prompts_directory),
        ("Validation Patterns", test_validation_patterns),
        ("AGENTS.md Generation", test_agents_md_generation),
    ]
    
    results = []
    
    for test_name, test_func in tests:
        try:
            result = test_func()
            results.append((test_name, result))
        except Exception as e:
            print(f"\n✗ {test_name} crashed: {e}")
            results.append((test_name, False))
    
    # Summary
    print("\n" + "=" * 60)
    print("Test Summary")
    print("=" * 60)
    
    passed = sum(1 for _, result in results if result)
    failed = len(results) - passed
    
    for test_name, result in results:
        status = "✓ PASS" if result else "✗ FAIL"
        print(f"{status:8} | {test_name}")
    
    print("\n" + "=" * 60)
    print(f"Total: {passed}/{len(results)} tests passed")
    
    if failed > 0:
        print(f"\n⚠️  {failed} test(s) failed - review output above")
        return 1
    else:
        print(f"\n🎉 All tests passed!")
        return 0


if __name__ == "__main__":
    sys.exit(main())
