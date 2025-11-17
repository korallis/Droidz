#!/bin/bash
#
# load-project-skills.sh - SessionStart Hook
#
# Analyzes project structure and loads relevant skills at session start
# Hook type: SessionStart
# Input: JSON with session info
# Output: Skill content to inject into context
#

set -euo pipefail

# Get the project directory
FACTORY_PROJECT_DIR="${FACTORY_PROJECT_DIR:-$(pwd)}"
SKILLS_DIR="$FACTORY_PROJECT_DIR/.factory/skills"

# Function to read and output a skill file
read_skill() {
    local skill_file="$1"
    if [[ -f "$skill_file" ]]; then
        echo ""
        echo "<!-- Auto-loaded project skill: $(basename "$skill_file" .md) -->"
        echo ""
        cat "$skill_file"
        echo ""
    fi
}

# Function to check if file exists in project
file_exists() {
    [[ -f "$FACTORY_PROJECT_DIR/$1" ]]
}

# Function to check if directory exists in project
dir_exists() {
    [[ -d "$FACTORY_PROJECT_DIR/$1" ]]
}

# Read package.json if it exists to detect dependencies
PACKAGE_JSON="$FACTORY_PROJECT_DIR/package.json"
DEPENDENCIES=""
if [[ -f "$PACKAGE_JSON" ]]; then
    DEPENDENCIES=$(cat "$PACKAGE_JSON" 2>/dev/null || echo "")
fi

echo "<!-- Droidz Skills System: Auto-loading project-specific skills -->"
echo ""

# TypeScript detection
if file_exists "tsconfig.json"; then
    read_skill "$SKILLS_DIR/typescript.md"
fi

# React detection
if echo "$DEPENDENCIES" | grep -q "\"react\""; then
    read_skill "$SKILLS_DIR/react.md"
fi

# Next.js detection
if echo "$DEPENDENCIES" | grep -q "\"next\"" || dir_exists "app" || file_exists "next.config.js" || file_exists "next.config.ts" || file_exists "next.config.mjs"; then
    read_skill "$SKILLS_DIR/nextjs-16.md"
fi

# Tailwind detection
if file_exists "tailwind.config.js" || file_exists "tailwind.config.ts" || echo "$DEPENDENCIES" | grep -q "\"tailwindcss\""; then
    read_skill "$SKILLS_DIR/tailwind-v4.md"
fi

# Convex detection
if dir_exists "convex" || echo "$DEPENDENCIES" | grep -q "\"convex\""; then
    read_skill "$SKILLS_DIR/convex.md"
fi

# Prisma detection
if file_exists "prisma/schema.prisma" || echo "$DEPENDENCIES" | grep -q "\"@prisma/client\""; then
    read_skill "$SKILLS_DIR/prisma.md"
    read_skill "$SKILLS_DIR/postgresql.md"
fi

# Drizzle detection
if echo "$DEPENDENCIES" | grep -q "\"drizzle-orm\""; then
    read_skill "$SKILLS_DIR/drizzle.md"
    read_skill "$SKILLS_DIR/postgresql.md"
fi

# Supabase detection
if echo "$DEPENDENCIES" | grep -q "\"@supabase/supabase-js\""; then
    read_skill "$SKILLS_DIR/supabase.md"
fi

# Neon detection (check for neon in connection string or env vars)
if echo "$DEPENDENCIES" | grep -q "\"@neondatabase/serverless\"" || file_exists ".env" && grep -q "neon.tech" "$FACTORY_PROJECT_DIR/.env" 2>/dev/null; then
    read_skill "$SKILLS_DIR/neon.md"
fi

# Clerk detection
if echo "$DEPENDENCIES" | grep -q "\"@clerk/"; then
    read_skill "$SKILLS_DIR/clerk.md"
fi

# Stripe detection
if echo "$DEPENDENCIES" | grep -q "\"stripe\""; then
    read_skill "$SKILLS_DIR/stripe.md"
fi

# Vercel detection (vercel.json or .vercel directory)
if file_exists "vercel.json" || dir_exists ".vercel"; then
    read_skill "$SKILLS_DIR/vercel.md"
fi

# Cloudflare Workers detection
if file_exists "wrangler.toml" || echo "$DEPENDENCIES" | grep -q "\"@cloudflare/workers"; then
    read_skill "$SKILLS_DIR/cloudflare-workers.md"
fi

# tRPC detection
if echo "$DEPENDENCIES" | grep -q "\"@trpc/"; then
    read_skill "$SKILLS_DIR/trpc.md"
fi

# TanStack Query detection
if echo "$DEPENDENCIES" | grep -q "\"@tanstack/react-query\""; then
    read_skill "$SKILLS_DIR/tanstack-query.md"
fi

# Testing frameworks detection
if echo "$DEPENDENCIES" | grep -qE "\"(jest|vitest|@testing-library|playwright|cypress)\""; then
    read_skill "$SKILLS_DIR/test-driven-development.md"
fi

# Always load security for any web project
if file_exists "package.json"; then
    read_skill "$SKILLS_DIR/security.md"
fi

# Load design skill if design files present
if dir_exists "design" || dir_exists "figma" || file_exists "design-system.md"; then
    read_skill "$SKILLS_DIR/design.md"
fi

echo ""
echo "<!-- Skills auto-loaded. Ready to assist with your project! -->"
echo ""

# Exit successfully
exit 0
