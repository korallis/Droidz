#!/bin/bash
#
# Apply Droid Symlink Workaround
# Called by /droidz-init to set up Factory.ai compatibility
#
# This is a non-interactive version that automatically:
# 1. Creates .json → .md symlinks for all droids
# 2. Adds .gitignore to exclude symlinks
# 3. Reports what was done
#

set -e

# Check if we're in a project with droids
if [ ! -d ".factory/droids" ]; then
    exit 0  # Silently skip if no droids directory
fi

cd .factory/droids

# Count .md files
md_count=$(ls -1 *.md 2>/dev/null | wc -l | tr -d ' ')

if [ "$md_count" -eq 0 ]; then
    exit 0  # No droids to process
fi

# Create symlinks
created=0
for md_file in *.md; do
    if [ -f "$md_file" ]; then
        base="${md_file%.md}"
        json_file="${base}.json"
        
        if [ ! -e "$json_file" ]; then
            ln -s "$md_file" "$json_file" 2>/dev/null && ((created++)) || true
        fi
    fi
done

# Create .gitignore if symlinks were created
if [ $created -gt 0 ]; then
    if [ ! -f ".gitignore" ]; then
        cat > .gitignore << 'EOF'
# Factory.ai symlink workaround (temporary)
# These symlinks work around a Factory.ai CLI bug that looks for .json
# instead of .md during parallel execution.
# Remove when https://github.com/factory-ai/factory-cli bug is fixed
*.json
EOF
    else
        if ! grep -q '*.json' .gitignore 2>/dev/null; then
            echo "" >> .gitignore
            echo "# Factory.ai symlink workaround (temporary)" >> .gitignore
            echo "*.json" >> .gitignore
        fi
    fi
fi

cd ../..

# Output result for droidz-init to display
echo "$created"
