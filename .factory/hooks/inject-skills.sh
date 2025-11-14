#!/usr/bin/env bash
# Skills Injection Hook for Factory.ai Droid CLI
# Automatically injects relevant coding standards and patterns based on user prompt

set -eo pipefail

# Read hook input from stdin
input=$(cat)
prompt=$(echo "$input" | jq -r '.prompt // ""')
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

# Detect TypeScript/React/Next.js
if echo "$prompt" | grep -qiE "typescript|react|next\.?js|\.tsx?|component|hook"; then
    typescript_skill=$(read_skill "$skills_dir/typescript.md")
    if [ -n "$typescript_skill" ]; then
        skills="${skills}\n\n### TypeScript Standards\n${typescript_skill}"
    fi
    
    react_skill=$(read_skill "$skills_dir/react.md")
    if [ -n "$react_skill" ]; then
        skills="${skills}\n\n### React Patterns\n${react_skill}"
    fi
fi

# Detect Tailwind CSS
if echo "$prompt" | grep -qiE "tailwind|css|style|design|ui|button|layout"; then
    tailwind_skill=$(read_skill "$skills_dir/tailwind-4.md")
    if [ -n "$tailwind_skill" ]; then
        skills="${skills}\n\n### Tailwind CSS Guidelines\n${tailwind_skill}"
    fi
fi

# Detect Convex
if echo "$prompt" | grep -qiE "convex|database|backend|query|mutation|action|storage"; then
    convex_skill=$(read_skill "$skills_dir/convex.md")
    if [ -n "$convex_skill" ]; then
        skills="${skills}\n\n### Convex Best Practices\n${convex_skill}"
    fi
fi

# Detect Testing
if echo "$prompt" | grep -qiE "test|testing|jest|vitest|playwright|cypress|spec"; then
    testing_skill=$(read_skill "$skills_dir/testing.md")
    if [ -n "$testing_skill" ]; then
        skills="${skills}\n\n### Testing Standards\n${testing_skill}"
    fi
fi

# Detect Security
if echo "$prompt" | grep -qiE "security|auth|authentication|password|token|api.?key|secret"; then
    security_skill=$(read_skill "$skills_dir/security.md")
    if [ -n "$security_skill" ]; then
        skills="${skills}\n\n### Security Requirements\n${security_skill}"
    fi
fi

# Detect Performance
if echo "$prompt" | grep -qiE "performance|optimize|speed|cache|lazy|async"; then
    perf_skill=$(read_skill "$skills_dir/performance.md")
    if [ -n "$perf_skill" ]; then
        skills="${skills}\n\n### Performance Guidelines\n${perf_skill}"
    fi
fi

# Detect Accessibility
if echo "$prompt" | grep -qiE "accessibility|a11y|aria|screen.?reader|semantic"; then
    a11y_skill=$(read_skill "$skills_dir/accessibility.md")
    if [ -n "$a11y_skill" ]; then
        skills="${skills}\n\n### Accessibility Standards\n${a11y_skill}"
    fi
fi

# Output skills content (stdout is automatically added to context for UserPromptSubmit!)
if [ -n "$skills" ]; then
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║           CODING STANDARDS AND PATTERNS                   ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    echo -e "$skills"
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║  Follow these standards in ALL code you write             ║"
    echo "╚════════════════════════════════════════════════════════════╝"
fi

exit 0
