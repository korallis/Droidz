#!/bin/bash
# Droidz v2.x → v3.0 Migration Script

set -euo pipefail

VERSION="3.0.0"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR=".droidz-v2-backup-${TIMESTAMP}"

echo "🤖 Droidz Migration: v2.x → v3.0"
echo "================================"
echo ""

# Check if already on v3.0
if [ ! -d ".droidz" ] && [ -f ".factory/commands/validate-init.md" ]; then
  echo "✅ Already on v3.0! No migration needed."
  exit 0
fi

# Step 1: Create backup
echo "📦 Step 1: Creating backup..."
if [ -d ".droidz" ]; then
  cp -r .droidz "$BACKUP_DIR"
  echo "   ✓ Backed up .droidz/ → $BACKUP_DIR/"
fi

if [ -d ".factory" ]; then
  cp -r .factory "${BACKUP_DIR}/.factory"
  echo "   ✓ Backed up .factory/ → $BACKUP_DIR/.factory/"
fi

# Step 2: Migrate specs
echo ""
echo "📝 Step 2: Migrating specs..."
if [ -d ".droidz/specs" ]; then
  mkdir -p .factory/specs/archived
  mv .droidz/specs/* .factory/specs/archived/ 2>/dev/null || true
  echo "   ✓ Moved specs to .factory/specs/archived/"
else
  echo "   ℹ️  No specs to migrate"
fi

# Step 3: Remove .droidz folder
echo ""
echo "🗑️  Step 3: Removing .droidz/ folder..."
if [ -d ".droidz" ]; then
  rm -rf .droidz/
  echo "   ✓ Removed .droidz/"
else
  echo "   ℹ️  .droidz/ not found (already removed)"
fi

# Step 4: Update .gitignore
echo ""
echo "📄 Step 4: Updating .gitignore..."
if [ -f ".gitignore" ]; then
  if ! grep -q ".factory/validation/.validation-cache/" .gitignore; then
    echo "   Adding v3.0 gitignore patterns..."
    cat >> .gitignore << 'EOF'

# Droidz v3.0
.factory/specs/active/
.factory/validation/.validation-cache/
EOF
    echo "   ✓ Updated .gitignore"
  else
    echo "   ✓ .gitignore already updated"
  fi
else
  echo "   ⚠️  No .gitignore found"
fi

# Step 5: Verify installation
echo ""
echo "🔍 Step 5: Verifying v3.0 installation..."

CHECKS_PASSED=0
CHECKS_TOTAL=6

# Check 1: Skills updated
if grep -q "Use when" .factory/skills/typescript/SKILL.md 2>/dev/null; then
  echo "   ✓ Skills format updated"
  ((CHECKS_PASSED++))
else
  echo "   ❌ Skills not updated"
fi

# Check 2: Droids have model: inherit
DROID_COUNT=$(find .factory/droids -name "*.md" -type f | wc -l | tr -d ' ')
INHERIT_COUNT=$(grep -r "^model: inherit" .factory/droids/ | wc -l | tr -d ' ')
if [ "$DROID_COUNT" -eq "$INHERIT_COUNT" ]; then
  echo "   ✓ All $DROID_COUNT droids use model: inherit"
  ((CHECKS_PASSED++))
else
  echo "   ⚠️  Some droids don't use model: inherit ($INHERIT_COUNT/$DROID_COUNT)"
fi

# Check 3: validate-init command exists
if [ -f ".factory/commands/validate-init.md" ]; then
  echo "   ✓ /validate-init command exists"
  ((CHECKS_PASSED++))
else
  echo "   ❌ /validate-init command missing"
fi

# Check 4: validate command exists
if [ -f ".factory/commands/validate.md" ]; then
  echo "   ✓ /validate command exists"
  ((CHECKS_PASSED++))
else
  echo "   ❌ /validate command missing"
fi

# Check 5: hooks settings.json exists
if [ -f ".factory/hooks/settings.json" ]; then
  echo "   ✓ Hooks settings.json exists"
  ((CHECKS_PASSED++))
else
  echo "   ❌ Hooks settings.json missing"
fi

# Check 6: No .droidz folder
if [ ! -d ".droidz" ]; then
  echo "   ✓ .droidz/ removed"
  ((CHECKS_PASSED++))
else
  echo "   ❌ .droidz/ still exists"
fi

# Summary
echo ""
echo "================================"
echo "📊 Migration Summary"
echo "================================"
echo ""
echo "Checks passed: $CHECKS_PASSED/$CHECKS_TOTAL"
echo ""

if [ $CHECKS_PASSED -eq $CHECKS_TOTAL ]; then
  echo "✅ Migration complete!"
  echo ""
  echo "Next steps:"
  echo "  1. Test: droid"
  echo "  2. Verify droids: /droids"
  echo "  3. Verify skills: /skills"
  echo "  4. Generate validation: /validate-init"
  echo "  5. Test validation: /validate"
  echo ""
  echo "Backup saved to: $BACKUP_DIR/"
  echo ""
  echo "If everything works, you can remove the backup:"
  echo "  rm -rf $BACKUP_DIR/"
else
  echo "⚠️  Migration incomplete ($CHECKS_PASSED/$CHECKS_TOTAL checks passed)"
  echo ""
  echo "To rollback:"
  echo "  1. Restore from backup: cp -r $BACKUP_DIR/.droidz ./"
  echo "  2. Restore .factory: rm -rf .factory && cp -r $BACKUP_DIR/.factory ./"
  echo "  3. Re-run migration or report issue"
  echo ""
  echo "Backup saved to: $BACKUP_DIR/"
fi

# Step 6: Rename command files to new primary names
echo ""
echo "🔄 Step 6: Renaming commands to primary names..."

FACTORY_DIR=".factory"

if [ -f "$FACTORY_DIR/commands/droidz-init.md" ]; then
    mv "$FACTORY_DIR/commands/droidz-init.md" "$FACTORY_DIR/commands/init.md" 2>/dev/null || true
    echo "   ✓ Renamed droidz-init.md → init.md"
fi

if [ -f "$FACTORY_DIR/commands/auto-parallel.md" ]; then
    mv "$FACTORY_DIR/commands/auto-parallel.md" "$FACTORY_DIR/commands/parallel.md" 2>/dev/null || true
    echo "   ✓ Renamed auto-parallel.md → parallel.md"
fi

if [ -f "$FACTORY_DIR/commands/droidz-build.md" ]; then
    mv "$FACTORY_DIR/commands/droidz-build.md" "$FACTORY_DIR/commands/build.md" 2>/dev/null || true
    echo "   ✓ Renamed droidz-build.md → build.md"
fi

# Step 7: Clean up deprecated files
echo ""
echo "🗑️  Step 7: Cleaning up deprecated files..."

# Remove old backup files
rm -f "$FACTORY_DIR/commands/"*.v2-backup 2>/dev/null || true
rm -f "$FACTORY_DIR/droids/"*.v2-backup 2>/dev/null || true

# Remove old installer scripts if present
rm -f "$FACTORY_DIR/scripts/installer.sh" 2>/dev/null || true

echo "   ✓ Cleaned up deprecated files"

echo ""
echo "📚 Documentation:"
echo "  - README.md - Overview and quick start"
echo "  - MIGRATION_V3.md - Detailed migration guide"
echo "  - VALIDATION.md - Validation system"
echo "  - SKILLS.md - Skills system"
echo "  - DROIDS.md - Custom droids"
echo ""
echo "🎉 Welcome to Droidz v3.0!"
