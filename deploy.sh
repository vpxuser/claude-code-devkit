#!/bin/bash
# Claude Code DevKit — Deploy to another project
# Usage:
#   bash deploy.sh /path/to/target-project          # Minimal: validation only
#   bash deploy.sh /path/to/target-project --full    # Full: validation + skill + commands
#   bash deploy.sh /path/to/target-project --dry-run # Preview only

set -euo pipefail

# ---- Config ----
DEVKIT_DIR="$(cd "$(dirname "$0")" && pwd)"
MODE="${2:-minimal}"
DRY_RUN=false
FULL=false

# ---- Helpers ----
print() { echo -e "\033[1;32m[deploy]\033[0m $1"; }
warn()  { echo -e "\033[1;33m[deploy]\033[0m $1"; }
error() { echo -e "\033[1;31m[deploy]\033[0m $1"; }

do_copy() {
  local src="$1" dst="$2"
  if [ "$DRY_RUN" = true ]; then
    echo "  would copy: $src → $dst"
  else
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    echo "  copied: $src → $dst"
  fi
}

# ---- Parse args ----
TARGET="${1:-}"
if [ -z "$TARGET" ]; then
  echo "Usage: bash deploy.sh /path/to/target-project [--full|--dry-run]"
  echo ""
  echo "Modes:"
  echo "  (default)  Minimal — validation script + hooks + /validate command"
  echo "  --full     Full — above + design philosophy skill + /generate-file command + guides"
  echo "  --dry-run  Preview what would be copied without making changes"
  exit 1
fi

if [ ! -d "$TARGET" ]; then
  error "Target directory does not exist: $TARGET"
  exit 1
fi

if [ "$MODE" = "--dry-run" ]; then
  DRY_RUN=true
elif [ "$MODE" = "--full" ]; then
  FULL=true
fi

# Normalize path
TARGET="$(cd "$TARGET" && pwd)"

echo ""
print "Deploying Claude Code DevKit to: $TARGET"
if [ "$DRY_RUN" = true ]; then
  print "Mode: DRY RUN (no changes)"
elif [ "$FULL" = true ]; then
  print "Mode: FULL (validation + commands + skill + guides)"
else
  print "Mode: MINIMAL (validation + /validate command)"
fi
echo ""

# =============================================
# 1. Core: Validation script
# =============================================
print "[1/4] Installing validation script..."
do_copy \
  "$DEVKIT_DIR/.claude/scripts/validate.sh" \
  "$TARGET/.claude/scripts/validate.sh"

if [ "$DRY_RUN" = false ]; then
  chmod +x "$TARGET/.claude/scripts/validate.sh"
fi

# =============================================
# 2. Commands
# =============================================
print "[2/4] Installing commands..."

do_copy \
  "$DEVKIT_DIR/.claude/commands/validate.md" \
  "$TARGET/.claude/commands/validate.md"

if [ "$FULL" = true ]; then
  do_copy \
    "$DEVKIT_DIR/.claude/commands/generate-file.md" \
    "$TARGET/.claude/commands/generate-file.md"
fi

# =============================================
# 3. Hooks (merge into target's settings.json)
# =============================================
print "[3/4] Configuring PostToolUse validation hook..."

TARGET_SETTINGS="$TARGET/.claude/settings.json"
TARGET_SETTINGS_DIR="$(dirname "$TARGET_SETTINGS")"

if [ "$DRY_RUN" = false ]; then
  mkdir -p "$TARGET_SETTINGS_DIR"
fi

# The validation hook to inject
if [ "$DRY_RUN" = true ]; then
  echo "  would merge hooks into: $TARGET_SETTINGS"
else
  if [ -f "$TARGET_SETTINGS" ]; then
    # Merge validation hook into existing settings.json
    jq '.hooks.PostToolUse = [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "bash .claude/scripts/validate.sh",
        "timeout": 30
      }]
    }]' "$TARGET_SETTINGS" > "${TARGET_SETTINGS}.tmp" && mv "${TARGET_SETTINGS}.tmp" "$TARGET_SETTINGS"
  else
    # Create new settings.json with hooks
    cat > "$TARGET_SETTINGS" << 'JSONEOF'
{
  "permissions": {
    "allow": ["Read", "Write", "Edit", "Glob", "Grep", "Bash"]
  },
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/scripts/validate.sh",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
JSONEOF
  fi
  echo "  hooks configured in: $TARGET_SETTINGS"
fi

# =============================================
# 4. Optional: Skill + Guides (--full only)
# =============================================
if [ "$FULL" = true ]; then
  print "[4/4] Installing design philosophy skill and guides..."

  # Design philosophy skill
  do_copy \
    "$DEVKIT_DIR/.claude/skills/claude-code-design-philosophy/SKILL.md" \
    "$TARGET/.claude/skills/claude-code-design-philosophy/SKILL.md"

  # Guides
  for guide in "$DEVKIT_DIR"/guides/*.md; do
    do_copy "$guide" "$TARGET/.claude/devkit-guides/$(basename "$guide")"
  done

  # Templates
  for tmpl in "$DEVKIT_DIR"/templates/*; do
    do_copy "$tmpl" "$TARGET/.claude/devkit-templates/$(basename "$tmpl")"
  done

  # Update target's CLAUDE.md to reference the skill
  TARGET_CLAUDE="$TARGET/.claude/CLAUDE.md"
  if [ -f "$TARGET_CLAUDE" ]; then
    if ! grep -q "claude-code-design-philosophy" "$TARGET_CLAUDE" 2>/dev/null; then
      echo "" >> "$TARGET_CLAUDE"
      echo "## DevKit Integration" >> "$TARGET_CLAUDE"
      echo "This project uses Claude Code DevKit for config file validation." >> "$TARGET_CLAUDE"
      echo "The design philosophy skill is at \`.claude/skills/claude-code-design-philosophy/SKILL.md\`" >> "$TARGET_CLAUDE"
      echo "  appended reference to .claude/CLAUDE.md"
    fi
  fi
fi

# =============================================
# Summary
# =============================================
echo ""
print "=== Deployment Complete ==="
echo ""
echo "Installed components:"
echo "  [✓] validate.sh        — Post-write validation engine"
echo "  [✓] /validate command  — Manual validation command"
echo "  [✓] PostToolUse hook   — Auto-validates Write/Edit on config files"
if [ "$FULL" = true ]; then
  echo "  [✓] Design skill       — claude-code-design-philosophy skill"
  echo "  [✓] /generate-file     — File generation command"
  echo "  [✓] Guides             — Reference guides in .claude/devkit-guides/"
  echo "  [✓] Templates          — File templates in .claude/devkit-templates/"
fi
echo ""
echo "Next steps:"
echo "  1. cd $TARGET && claude"
echo "  2. Try: /validate"
if [ "$FULL" = true ]; then
  echo "  3. Try: /generate-file skill"
fi
echo ""
echo "To uninstall, remove:"
echo "  .claude/scripts/validate.sh"
echo "  .claude/commands/validate.md"
if [ "$FULL" = true ]; then
  echo "  .claude/skills/claude-code-design-philosophy/"
  echo "  .claude/commands/generate-file.md"
  echo "  .claude/devkit-guides/"
  echo "  .claude/devkit-templates/"
fi
echo "  And remove the PostToolUse hook from .claude/settings.json"
