#!/usr/bin/env bash
# File-based Skills Injection Hook for Factory.ai Droid CLI
# Injects relevant coding standards based on file type before Write/Edit/MultiEdit

set -eo pipefail

# Read hook input
input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name // ""')
file_path=$(echo "$input" | jq -r '.tool_input.file_path // ""')
cwd=$(echo "$input" | jq -r '.cwd // "."')

# Only process Write/Edit/MultiEdit tools
if [[ ! "$tool_name" =~ ^(Write|Edit|MultiEdit)$ ]]; then
    echo "{}"
    exit 0
fi

# Skip if no file path
if [ -z "$file_path" ]; then
    echo "{}"
    exit 0
fi

skills_dir="$cwd/.factory/skills"
additional_context=""

# Function to safely read skill file
read_skill() {
    local skill_file="$1"
    if [ -f "$skill_file" ]; then
        cat "$skill_file"
    fi
}

# Detect file type and inject relevant skills
case "$file_path" in
    *.ts|*.tsx)
        skill=$(read_skill "$skills_dir/typescript.md")
        if [ -n "$skill" ]; then
            additional_context="${additional_context}### TypeScript Standards for this file:\n${skill}\n\n"
        fi
        
        if [[ "$file_path" =~ \.tsx$ ]]; then
            react_skill=$(read_skill "$skills_dir/react.md")
            if [ -n "$react_skill" ]; then
                additional_context="${additional_context}### React Component Standards:\n${react_skill}\n\n"
            fi
        fi
        ;;
    
    *.css|*.scss|*.sass)
        skill=$(read_skill "$skills_dir/tailwind-4.md")
        if [ -n "$skill" ]; then
            additional_context="${additional_context}### Tailwind/CSS Standards:\n${skill}\n\n"
        fi
        ;;
    
    *convex/*.ts)
        skill=$(read_skill "$skills_dir/convex.md")
        if [ -n "$skill" ]; then
            additional_context="${additional_context}### Convex Function Standards:\n${skill}\n\n"
        fi
        ;;
    
    *.test.ts|*.test.tsx|*.spec.ts|*.spec.tsx)
        skill=$(read_skill "$skills_dir/testing.md")
        if [ -n "$skill" ]; then
            additional_context="${additional_context}### Testing Standards:\n${skill}\n\n"
        fi
        ;;
esac

# Return JSON with additionalContext
if [ -n "$additional_context" ]; then
    # Escape for JSON
    context_escaped=$(echo "$additional_context" | jq -Rs .)
    cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "additionalContext": $context_escaped
  }
}
EOF
else
    echo "{}"
fi

exit 0
