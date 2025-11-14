#!/usr/bin/env bash
# SessionStart Skills Injection Hook for Factory.ai Droid CLI
# Loads project-relevant skills once at session start

set -eo pipefail

# Read hook input
input=$(cat)
cwd=$(echo "$input" | jq -r '.cwd // "."')

skills_dir="$cwd/.factory/skills"
skills=""

# Function to safely read skill file
read_skill() {
    local skill_file="$1"
    if [ -f "$skill_file" ]; then
        cat "$skill_file"
    fi
}

# Check for TypeScript
if [ -f "$cwd/tsconfig.json" ] || [ -f "$cwd/package.json" ]; then
    if grep -q "typescript" "$cwd/package.json" 2>/dev/null; then
        typescript_skill=$(read_skill "$skills_dir/typescript.md")
        if [ -n "$typescript_skill" ]; then
            skills="${skills}\n\n### TypeScript Standards\n${typescript_skill}"
        fi
    fi
fi

# Check for React/Next.js
if [ -f "$cwd/package.json" ]; then
    if grep -qE "\"react\"|\"next\"" "$cwd/package.json" 2>/dev/null; then
        react_skill=$(read_skill "$skills_dir/react.md")
        if [ -n "$react_skill" ]; then
            skills="${skills}\n\n### React Patterns\n${react_skill}"
        fi
    fi
fi

# Check for Tailwind
if grep -q "tailwindcss" "$cwd/package.json" 2>/dev/null || [ -f "$cwd/tailwind.config.js" ] || [ -f "$cwd/tailwind.config.ts" ]; then
    tailwind_skill=$(read_skill "$skills_dir/tailwind-4.md")
    if [ -n "$tailwind_skill" ]; then
        skills="${skills}\n\n### Tailwind CSS Guidelines\n${tailwind_skill}"
    fi
fi

# Check for Convex
if [ -d "$cwd/convex" ]; then
    convex_skill=$(read_skill "$skills_dir/convex.md")
    if [ -n "$convex_skill" ]; then
        skills="${skills}\n\n### Convex Best Practices\n${convex_skill}"
    fi
fi

# Always load security and testing (universal)
security_skill=$(read_skill "$skills_dir/security.md")
if [ -n "$security_skill" ]; then
    skills="${skills}\n\n### Security Requirements\n${security_skill}"
fi

testing_skill=$(read_skill "$skills_dir/testing.md")
if [ -n "$testing_skill" ]; then
    skills="${skills}\n\n### Testing Standards\n${testing_skill}"
fi

# Output skills (stdout is automatically added to context for SessionStart!)
if [ -n "$skills" ]; then
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║        PROJECT CODING STANDARDS LOADED                    ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    echo -e "$skills"
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║  These standards apply to ALL code in this project        ║"
    echo "╚════════════════════════════════════════════════════════════╝"
fi

exit 0
