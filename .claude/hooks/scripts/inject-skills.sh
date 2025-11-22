#!/bin/bash
#
# inject-skills.sh - UserPromptSubmit Hook
#
# Detects keywords in user prompts and injects relevant skills
# Hook type: UserPromptSubmit
# Input: JSON with user prompt
# Output: Skill content to inject into context
#

set -euo pipefail

# Get the project directory
FACTORY_PROJECT_DIR="${FACTORY_PROJECT_DIR:-$(pwd)}"
SKILLS_DIR="$FACTORY_PROJECT_DIR/.factory/skills"

# Read JSON input from stdin
INPUT=$(cat)

# Extract prompt from JSON (handle both "prompt" and "content" fields)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // .content // ""' 2>/dev/null || echo "")

# If no prompt found, exit silently
if [[ -z "$PROMPT" ]]; then
    exit 0
fi

# Function to read and output a skill file
read_skill() {
    local skill_file="$1"
    if [[ -f "$skill_file" ]]; then
        echo ""
        echo "<!-- Auto-injected skill: $(basename "$skill_file" .md) -->"
        echo ""
        cat "$skill_file"
        echo ""
    fi
}

# Convert prompt to lowercase for case-insensitive matching
prompt_lower=$(echo "$PROMPT" | tr '[:upper:]' '[:lower:]')

# TypeScript detection
if echo "$prompt_lower" | grep -qE "typescript|\.ts|\.tsx|type|interface"; then
    read_skill "$SKILLS_DIR/typescript.md"
fi

# React detection
if echo "$prompt_lower" | grep -qE "react|component|jsx|tsx|hook|usestate|useeffect"; then
    read_skill "$SKILLS_DIR/react.md"
fi

# Tailwind detection
if echo "$prompt_lower" | grep -qE "tailwind|tw-|utility.class|styling|css"; then
    read_skill "$SKILLS_DIR/tailwind-v4.md"
fi

# Convex detection
if echo "$prompt_lower" | grep -qE "convex|mutation|query|action|validator|ctx\.db"; then
    read_skill "$SKILLS_DIR/convex.md"
fi

# Next.js detection
if echo "$prompt_lower" | grep -qE "next\.js|nextjs|app.router|server.component|client.component"; then
    read_skill "$SKILLS_DIR/nextjs-16.md"
fi

# Prisma detection
if echo "$prompt_lower" | grep -qE "prisma|prisma.client|schema.prisma|@prisma"; then
    read_skill "$SKILLS_DIR/prisma.md"
fi

# Drizzle detection
if echo "$prompt_lower" | grep -qE "drizzle|drizzle.orm|pgTable|serial|varchar"; then
    read_skill "$SKILLS_DIR/drizzle.md"
fi

# PostgreSQL detection
if echo "$prompt_lower" | grep -qE "postgres|postgresql|pg|database|sql|query"; then
    read_skill "$SKILLS_DIR/postgresql.md"
fi

# Supabase detection
if echo "$prompt_lower" | grep -qE "supabase|supabase.client|auth\.signIn"; then
    read_skill "$SKILLS_DIR/supabase.md"
fi

# Neon detection
if echo "$prompt_lower" | grep -qE "neon|neon.tech|serverless.postgres"; then
    read_skill "$SKILLS_DIR/neon.md"
fi

# Clerk detection
if echo "$prompt_lower" | grep -qE "clerk|clerk.com|auth|authentication|sign.in|sign.up"; then
    read_skill "$SKILLS_DIR/clerk.md"
fi

# Stripe detection
if echo "$prompt_lower" | grep -qE "stripe|payment|checkout|subscription|stripe.com"; then
    read_skill "$SKILLS_DIR/stripe.md"
fi

# Vercel detection
if echo "$prompt_lower" | grep -qE "vercel|vercel.com|deployment|edge.function"; then
    read_skill "$SKILLS_DIR/vercel.md"
fi

# Cloudflare Workers detection
if echo "$prompt_lower" | grep -qE "cloudflare|workers|edge|wrangler"; then
    read_skill "$SKILLS_DIR/cloudflare-workers.md"
fi

# tRPC detection
if echo "$prompt_lower" | grep -qE "trpc|procedure|router|mutation"; then
    read_skill "$SKILLS_DIR/trpc.md"
fi

# TanStack Query detection
if echo "$prompt_lower" | grep -qE "tanstack|react.query|usequery|usemutation|query.client"; then
    read_skill "$SKILLS_DIR/tanstack-query.md"
fi

# Testing detection
if echo "$prompt_lower" | grep -qE "test|testing|jest|vitest|playwright|cypress|spec|\.test\."; then
    read_skill "$SKILLS_DIR/test-driven-development.md"
    read_skill "$SKILLS_DIR/testing-anti-patterns.md"
fi

# Design detection
if echo "$prompt_lower" | grep -qE "design|ui|ux|mockup|figma|wireframe|prototype"; then
    read_skill "$SKILLS_DIR/design.md"
fi

# Security is always loaded for sensitive operations
if echo "$prompt_lower" | grep -qE "auth|password|secret|token|api.key|encrypt|hash|security|vulnerability|xss|sql.injection|csrf"; then
    read_skill "$SKILLS_DIR/security.md"
fi

# Debugging detection
if echo "$prompt_lower" | grep -qE "debug|bug|error|fix|issue|problem|crash|fail"; then
    read_skill "$SKILLS_DIR/systematic-debugging.md"
    read_skill "$SKILLS_DIR/root-cause-tracing.md"
fi

# Git worktrees detection
if echo "$prompt_lower" | grep -qE "worktree|git.worktree|parallel.branch"; then
    read_skill "$SKILLS_DIR/using-git-worktrees.md"
fi

# Code review detection
if echo "$prompt_lower" | grep -qE "code.review|review|pr|pull.request|feedback"; then
    read_skill "$SKILLS_DIR/requesting-code-review.md"
    read_skill "$SKILLS_DIR/receiving-code-review.md"
fi

# Exit successfully
exit 0
