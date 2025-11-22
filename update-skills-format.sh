#!/bin/bash
# Update all skills to v3.0 format
# Changes: "Auto-activates when" → "Use when"
#          "Automatically activates when" → "Use when"

set -euo pipefail

SKILLS_DIR="/Users/leebarry/Development/Droidz/.factory/skills"
COUNT=0

echo "🔄 Updating skills to v3.0 format..."

# Find all SKILL.md files
while IFS= read -r file; do
  # Check if file contains patterns that need updating
  if grep -qE "(Auto-activates when|Automatically activates when)" "$file"; then
    echo "  Updating: $(basename "$(dirname "$file")")/SKILL.md"
    
    # Use sed to replace patterns in the description line
    # macOS sed requires -i '' for in-place editing
    sed -i '' 's/Auto-activates when/Use when/g' "$file"
    sed -i '' 's/Automatically activates when/Use when/g' "$file"
    
    ((COUNT++))
  fi
done < <(find "$SKILLS_DIR" -name "SKILL.md" -type f)

echo "✅ Updated $COUNT skills to v3.0 format"
echo ""
echo "Verifying updates..."
REMAINING=$(find "$SKILLS_DIR" -name "SKILL.md" -type f -exec grep -l "Auto-activates" {} \; | wc -l | tr -d ' ')
echo "✓ Skills still with 'Auto-activates': $REMAINING (should be 0)"
