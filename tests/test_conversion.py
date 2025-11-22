#!/usr/bin/env python3
"""
Test conversion engine with real Claude Code files
"""

import sys
import os
from pathlib import Path

# Add installer to path
sys.path.insert(0, str(Path(__file__).parent.parent / "installer"))

def test_shell_command_detection():
    """Test detection of shell commands in markdown"""
    import re
    
    # Test regex pattern for shell commands
    shell_pattern = re.compile(r'!\`([^`]+)\`')
    
    test_cases = [
        # Simple commands
        ('!`npm test`', True, 'npm test'),
        ('!`git status`', True, 'git status'),
        
        # Commands in context
        ('Run the tests:\n!`npm test`\nCheck results', True, 'npm test'),
        
        # Complex bash
        ('!`if [ -f package.json ]; then npm test; fi`', True, 'if [ -f package.json ]; then npm test; fi'),
        
        # Not commands
        ('Use backticks for code', False, None),
        ('The `npm` package manager', False, None),
    ]
    
    print("Testing shell command detection...")
    passed = 0
    failed = 0
    
    for content, should_detect, expected_cmd in test_cases:
        matches = shell_pattern.findall(content)
        detected = len(matches) > 0
        
        if detected == should_detect:
            if should_detect and matches:
                if expected_cmd in matches[0]:
                    print(f"  ✓ Correctly detected: {expected_cmd[:30]}...")
                    passed += 1
                else:
                    print(f"  ✗ Detected wrong command: {matches[0][:30]}...")
                    failed += 1
            else:
                print(f"  ✓ Correctly skipped: {content[:30]}...")
                passed += 1
        else:
            print(f"  ✗ Detection failed for: {content[:30]}...")
            failed += 1
    
    print(f"\nResults: {passed} passed, {failed} failed")
    return failed == 0


def test_frontmatter_parsing():
    """Test YAML frontmatter parsing"""
    from converters import CommandToPromptConverter
    
    converter = CommandToPromptConverter()
    
    test_content = """---
model: inherit
tools: []
description: Test agent
---

# Test Agent

Some content here.
"""
    
    print("\nTesting frontmatter parsing...")
    
    try:
        frontmatter, body = converter._extract_frontmatter(test_content)
        
        if frontmatter and 'model' in frontmatter:
            print(f"  ✓ Frontmatter parsed: {list(frontmatter.keys())}")
        else:
            print(f"  ✗ Frontmatter parsing failed")
            return False
            
        if "# Test Agent" in body:
            print(f"  ✓ Body extracted correctly")
        else:
            print(f"  ✗ Body extraction failed")
            return False
            
        return True
        
    except Exception as e:
        print(f"  ✗ Exception: {e}")
        return False


def test_conversion_pipeline():
    """Test full conversion pipeline"""
    import re
    
    claude_content = """---
model: inherit
tools: []
---

# Test Agent

This agent tests features.

## Process

1. Run tests:
   !`npm test`

2. Check status:
   !`git status`

3. Verify results
"""
    
    print("\nTesting conversion pipeline...")
    
    try:
        # Simulate conversion process
        codex_content = claude_content
        
        # Remove Factory.ai specific frontmatter
        codex_content = re.sub(r'^model:\s*inherit\s*$', '', codex_content, flags=re.MULTILINE)
        codex_content = re.sub(r'^tools:\s*\[.*?\]\s*$', '', codex_content, flags=re.MULTILINE)
        
        # Convert shell commands to instructions
        codex_content = re.sub(r'!\`([^`]+)\`', r'Execute: \1', codex_content)
        
        # Add description if frontmatter exists
        if codex_content.startswith('---'):
            codex_content = codex_content.replace('---\n', '---\ndescription: Test agent\n', 1)
        
        # Verify conversions
        checks = [
            ('model: inherit' not in codex_content, "Removed 'model: inherit'"),
            ('tools: []' not in codex_content, "Removed 'tools: []'"),
            ('!`' not in codex_content, "Removed shell execution syntax"),
            ('description:' in codex_content, "Added description field"),
            ('npm test' in codex_content, "Preserved command reference"),
        ]
        
        passed = sum(1 for check, _ in checks if check)
        
        for check, description in checks:
            status = "✓" if check else "✗"
            print(f"  {status} {description}")
        
        return passed == len(checks)
        
    except Exception as e:
        print(f"  ✗ Exception: {e}")
        import traceback
        traceback.print_exc()
        return False


def test_codex_prompt_validation():
    """Test validation of generated Codex prompts"""
    print("\nValidating Codex prompts...")
    
    prompts_dir = Path(__file__).parent.parent / "templates" / "codex" / "prompts"
    
    if not prompts_dir.exists():
        print(f"  ✗ Prompts directory not found: {prompts_dir}")
        return False
    
    prompts = list(prompts_dir.glob("*.md"))
    
    if not prompts:
        print(f"  ✗ No prompts found in {prompts_dir}")
        return False
    
    print(f"  Found {len(prompts)} prompts to validate")
    
    issues = []
    
    for prompt_file in prompts:
        content = prompt_file.read_text()
        
        # Check for frontmatter
        if not content.startswith('---'):
            issues.append(f"{prompt_file.name}: Missing frontmatter")
        
        # Check for Claude Code specific syntax
        if '!`' in content:
            issues.append(f"{prompt_file.name}: Contains shell execution syntax (!`)")
        
        if 'model: inherit' in content:
            issues.append(f"{prompt_file.name}: Contains 'model: inherit'")
        
        if 'tools: [' in content:
            issues.append(f"{prompt_file.name}: Contains 'tools:' field")
    
    if issues:
        print("\n  Issues found:")
        for issue in issues:
            print(f"    ✗ {issue}")
        return False
    else:
        print(f"  ✓ All {len(prompts)} prompts validated successfully")
        return True


def test_installer_structure():
    """Test installer package structure"""
    print("\nTesting installer structure...")
    
    installer_dir = Path(__file__).parent.parent / "installer"
    
    required_files = [
        '__init__.py',
        'cli.py',
        'compatibility.py',
        'components.py',
        'converters.py',
        'validators.py',
        'installer_codex.py',
    ]
    
    passed = 0
    failed = 0
    
    for filename in required_files:
        filepath = installer_dir / filename
        if filepath.exists():
            print(f"  ✓ {filename}")
            passed += 1
        else:
            print(f"  ✗ {filename} not found")
            failed += 1
    
    return failed == 0


def main():
    """Run all tests"""
    print("=" * 60)
    print("Droidz v4.0 - Conversion Engine Tests")
    print("=" * 60)
    
    tests = [
        ("Shell Command Detection", test_shell_command_detection),
        ("Frontmatter Parsing", test_frontmatter_parsing),
        ("Conversion Pipeline", test_conversion_pipeline),
        ("Codex Prompt Validation", test_codex_prompt_validation),
        ("Installer Structure", test_installer_structure),
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
