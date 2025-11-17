#!/bin/bash
#
# inject-file-skills.sh - PreToolUse Hook
#
# Detects file types being edited and injects relevant skills
# Hook type: PreToolUse (triggered before Write/Edit/MultiEdit)
# Input: JSON with tool name and parameters
# Output: Skill content to inject into context
#

set -euo pipefail

# Get the project directory
FACTORY_PROJECT_DIR="${FACTORY_PROJECT_DIR:-$(pwd)}"
SKILLS_DIR="$FACTORY_PROJECT_DIR/.factory/skills"

# Read JSON input from stdin
INPUT=$(cat)

# Extract tool name and file path
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // .tool // ""' 2>/dev/null || echo "")
FILE_PATH=$(echo "$INPUT" | jq -r '.parameters.file_path // .file_path // ""' 2>/dev/null || echo "")

# If no file path found, exit silently
if [[ -z "$FILE_PATH" ]]; then
    exit 0
fi

# Function to read and output a skill file
read_skill() {
    local skill_file="$1"
    if [[ -f "$skill_file" ]]; then
        echo ""
        echo "<!-- Auto-injected skill for $FILE_PATH: $(basename "$skill_file" .md) -->"
        echo ""
        cat "$skill_file"
        echo ""
    fi
}

# Get file extension
FILE_EXT="${FILE_PATH##*.}"
FILE_NAME=$(basename "$FILE_PATH")

# TypeScript/JavaScript files
if [[ "$FILE_EXT" == "ts" ]] || [[ "$FILE_EXT" == "tsx" ]] || [[ "$FILE_EXT" == "js" ]] || [[ "$FILE_EXT" == "jsx" ]]; then
    read_skill "$SKILLS_DIR/typescript.md"
fi

# React files (tsx/jsx)
if [[ "$FILE_EXT" == "tsx" ]] || [[ "$FILE_EXT" == "jsx" ]]; then
    read_skill "$SKILLS_DIR/react.md"
fi

# Next.js specific files
if [[ "$FILE_PATH" =~ app/.*page\.tsx ]] || [[ "$FILE_PATH" =~ app/.*layout\.tsx ]] || [[ "$FILE_PATH" =~ app/.*route\.ts ]]; then
    read_skill "$SKILLS_DIR/nextjs-16.md"
fi

# Convex files
if [[ "$FILE_PATH" =~ ^convex/ ]] || [[ "$FILE_PATH" =~ convex\. ]]; then
    read_skill "$SKILLS_DIR/convex.md"
fi

# CSS/Tailwind files
if [[ "$FILE_EXT" == "css" ]] || [[ "$FILE_PATH" =~ tailwind ]] || [[ "$FILE_PATH" =~ styles ]]; then
    read_skill "$SKILLS_DIR/tailwind-v4.md"
fi

# Prisma schema files
if [[ "$FILE_NAME" == "schema.prisma" ]] || [[ "$FILE_PATH" =~ prisma/ ]]; then
    read_skill "$SKILLS_DIR/prisma.md"
    read_skill "$SKILLS_DIR/postgresql.md"
fi

# Drizzle files
if [[ "$FILE_PATH" =~ drizzle ]] || [[ "$FILE_PATH" =~ schema\.ts ]]; then
    read_skill "$SKILLS_DIR/drizzle.md"
    read_skill "$SKILLS_DIR/postgresql.md"
fi

# Test files
if [[ "$FILE_PATH" =~ \.test\. ]] || [[ "$FILE_PATH" =~ \.spec\. ]] || [[ "$FILE_PATH" =~ __tests__/ ]] || [[ "$FILE_PATH" =~ tests/ ]]; then
    read_skill "$SKILLS_DIR/test-driven-development.md"
    read_skill "$SKILLS_DIR/testing-anti-patterns.md"
fi

# API route files
if [[ "$FILE_PATH" =~ /api/ ]] || [[ "$FILE_PATH" =~ route\.ts ]]; then
    read_skill "$SKILLS_DIR/security.md"
fi

# tRPC files
if [[ "$FILE_PATH" =~ trpc ]] || [[ "$FILE_PATH" =~ router\.ts ]]; then
    read_skill "$SKILLS_DIR/trpc.md"
fi

# Database migration files
if [[ "$FILE_PATH" =~ migrations/ ]] || [[ "$FILE_PATH" =~ \.sql$ ]]; then
    read_skill "$SKILLS_DIR/postgresql.md"
fi

# Environment files - always inject security
if [[ "$FILE_NAME" == ".env" ]] || [[ "$FILE_NAME" =~ \.env\. ]]; then
    read_skill "$SKILLS_DIR/security.md"
fi

# Config files
if [[ "$FILE_NAME" =~ config\. ]] || [[ "$FILE_NAME" =~ \.config\. ]]; then
    # Detect which framework/tool
    if [[ "$FILE_NAME" =~ tailwind ]]; then
        read_skill "$SKILLS_DIR/tailwind-v4.md"
    elif [[ "$FILE_NAME" =~ next ]]; then
        read_skill "$SKILLS_DIR/nextjs-16.md"
    elif [[ "$FILE_NAME" =~ vercel ]]; then
        read_skill "$SKILLS_DIR/vercel.md"
    elif [[ "$FILE_NAME" =~ wrangler ]]; then
        read_skill "$SKILLS_DIR/cloudflare-workers.md"
    fi
fi

# Stripe integration files
if [[ "$FILE_PATH" =~ stripe ]] || [[ "$FILE_PATH" =~ payment ]]; then
    read_skill "$SKILLS_DIR/stripe.md"
    read_skill "$SKILLS_DIR/security.md"
fi

# Auth files
if [[ "$FILE_PATH" =~ auth ]] || [[ "$FILE_PATH" =~ clerk ]]; then
    read_skill "$SKILLS_DIR/clerk.md"
    read_skill "$SKILLS_DIR/security.md"
fi

# Supabase files
if [[ "$FILE_PATH" =~ supabase ]]; then
    read_skill "$SKILLS_DIR/supabase.md"
fi

# Deployment files
if [[ "$FILE_NAME" == "vercel.json" ]] || [[ "$FILE_PATH" =~ \.vercel/ ]]; then
    read_skill "$SKILLS_DIR/vercel.md"
fi

if [[ "$FILE_NAME" == "wrangler.toml" ]] || [[ "$FILE_PATH" =~ workers/ ]]; then
    read_skill "$SKILLS_DIR/cloudflare-workers.md"
fi

# Exit successfully
exit 0
