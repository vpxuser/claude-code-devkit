#!/bin/bash
# Claude Code DevKit — Deploy to another project
# Usage:
#   bash deploy.sh /path/to/target-project          # Minimal: validation + permissions + hooks
#   bash deploy.sh /path/to/target-project --full   # Full: above + skill + commands + guides
#   bash deploy.sh /path/to/target-project --dry-run # Preview only
#   bash deploy.sh --diagnose /path/to/target-project  # Check project readiness

set -euo pipefail

# ---- Config ----
DEVKIT_DIR="$(cd "$(dirname "$0")" && pwd)"
MODE="${2:-minimal}"
DRY_RUN=false
FULL=false
DIAGNOSE=false

# Required permissions for the validation hook to function
REQUIRED_PERMISSIONS=(
  "Bash(bash .claude/scripts/validate.sh*)"
  "Bash(jq *)"
)

# ---- Colors ----
print() { echo -e "\033[1;32m[deploy]\033[0m $1"; }
warn()  { echo -e "\033[1;33m[deploy]\033[0m $1"; }
error() { echo -e "\033[1;31m[deploy]\033[0m $1"; }
bold()  { echo -e "\033[1m$1\033[0m"; }

# ---- Helpers ----
do_copy() {
  local src="$1" dst="$2"
  if [ "$DRY_RUN" = true ]; then
    echo "  [DRY-RUN] would copy: $(basename "$src") → $dst"
  else
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    echo "  [COPY] $(basename "$src")"
  fi
}

check_jq() {
  if ! command -v jq &> /dev/null; then
    error "jq is required but not installed."
    echo "  Install:  winget install jq  (Windows)  |  apt install jq  (Linux)  |  brew install jq  (macOS)"
    exit 1
  fi
}

# Check if an item exists in a jq array
perm_exists() {
  local settings="$1" perm="$2"
  jq -e --arg perm "$perm" '.permissions.allow // [] | index($perm) != null' "$settings" > /dev/null 2>&1
}

# ---- Parse args ----
if [ "$1" = "--diagnose" ] || [ "$1" = "--check" ]; then
  DIAGNOSE=true
  TARGET="${2:-}"
elif [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
  echo "Claude Code DevKit — Deploy to another project"
  echo ""
  echo "Usage:"
  echo "  bash deploy.sh /path/to/target-project           Minimal deployment"
  echo "  bash deploy.sh /path/to/target-project --full    Full deployment"
  echo "  bash deploy.sh /path/to/target-project --dry-run Preview only"
  echo "  bash deploy.sh --diagnose /path/to/target        Check project readiness"
  echo ""
  echo "Modes:"
  echo "  (default)  Minimal — validation script + permissions + hooks + /validate command"
  echo "  --full     Full    — above + design philosophy skill + /generate-file + guides + templates"
  echo "  --dry-run  Preview what would be copied/merged without making changes"
  echo "  --diagnose Analyze target project for existing devkit state and potential issues"
  exit 0
else
  TARGET="${1:-}"
fi

if [ "$MODE" = "--dry-run" ]; then
  DRY_RUN=true
  MODE="minimal"
elif [ "$MODE" = "--full" ]; then
  FULL=true
fi

if [ -z "$TARGET" ]; then
  error "Target directory is required"
  echo "Usage: bash deploy.sh /path/to/target-project [--full|--dry-run|--diagnose]"
  exit 1
fi

if [ ! -d "$TARGET" ]; then
  error "Target directory does not exist: $TARGET"
  exit 1
fi

# Normalize path
TARGET="$(cd "$TARGET" && pwd)"

# =============================================
# DIAGNOSE MODE
# =============================================
run_diagnose() {
  check_jq
  echo ""
  bold "═══ DevKit Deployment Diagnostics ═══"
  echo "  Target: $TARGET"
  echo ""

  local TARGET_SETTINGS="$TARGET/.claude/settings.json"
  # ... rest of diagnose
  if [ -f "$TARGET_SETTINGS" ]; then
    echo "  [settings.json] EXISTS"

    # Check permissions
    if jq -e '.permissions.allow' "$TARGET_SETTINGS" > /dev/null 2>&1; then
      local allow_count
      allow_count=$(jq '.permissions.allow | length' "$TARGET_SETTINGS")
      echo "    permissions.allow: $allow_count entries"
      for perm in "${REQUIRED_PERMISSIONS[@]}"; do
        if perm_exists "$TARGET_SETTINGS" "$perm"; then
          echo "    [OK] $perm"
        else
          warn "    [MISSING] $perm"
        fi
      done
    else
      warn "    permissions.allow: NOT FOUND"
    fi

    # Check hooks
    if jq -e '.hooks.PostToolUse' "$TARGET_SETTINGS" > /dev/null 2>&1; then
      local hook_count
      hook_count=$(jq '.hooks.PostToolUse | length' "$TARGET_SETTINGS")
      echo "    hooks.PostToolUse: $hook_count entry(s)"
    else
      warn "    hooks.PostToolUse: NOT CONFIGURED"
    fi

    # Detect non-standard keys
    local valid_keys="permissions hooks mcpServers model theme env includeCoAuthoredBy outputStyle"
    local keys
    keys=$(jq -r 'keys[]' "$TARGET_SETTINGS" 2>/dev/null | tr -d '\r' || echo "")
    for key in $keys; do
      if ! echo " $valid_keys " | grep -q " $key "; then
        warn "    Non-standard key: '$key'"
      fi
    done

    # Check for empty model field
    local model_val
    model_val=$(jq -r '.model // ""' "$TARGET_SETTINGS")
    if [ "$model_val" = "" ] && jq -e '.model' "$TARGET_SETTINGS" > /dev/null 2>&1; then
      warn "    'model' field is empty string — consider removing"
    fi
  else
    warn "  [settings.json] NOT FOUND — will be created"
  fi

  # Check validate.sh
  if [ -f "$TARGET/.claude/scripts/validate.sh" ]; then
    echo "  [validate.sh] EXISTS"
  else
    warn "  [validate.sh] NOT FOUND"
  fi

  # Check commands
  if [ -f "$TARGET/.claude/commands/validate.md" ]; then
    echo "  [/validate command] EXISTS"
  else
    warn "  [/validate command] NOT FOUND"
  fi

  # Check design philosophy skill
  if [ -f "$TARGET/.claude/skills/design-philosophy/SKILL.md" ]; then
    echo "  [design-philosophy skill] EXISTS"
  else
    warn "  [design-philosophy skill] NOT FOUND"
  fi

  # Check jq
  if command -v jq &> /dev/null; then
    local jq_ver
    jq_ver=$(jq --version 2>/dev/null || echo "unknown")
    echo "  [jq] AVAILABLE ($jq_ver)"
  else
    error "  [jq] NOT FOUND — required by validate.sh and deploy script"
  fi

  echo ""
  bold "═══ Diagnostics Complete ═══"
  exit 0
}

if [ "$DIAGNOSE" = true ]; then
  run_diagnose
fi

# =============================================
# DEPLOYMENT
# =============================================
run_deploy() {
  check_jq

  echo ""
  print "Deploying Claude Code DevKit to: $TARGET"
  if [ "$DRY_RUN" = true ]; then
    print "Mode: DRY RUN — no files will be written"
  elif [ "$FULL" = true ]; then
    print "Mode: FULL (validation + commands + skill + guides + templates)"
  else
    print "Mode: MINIMAL (validation + permissions + hooks + /validate command)"
  fi
  echo ""

  # Track what was done for summary
  local INSTALLED=()

  # =============================================
  # 1. Check dependencies
  # =============================================
  print "[1/5] Checking dependencies..."
  local jq_ver
  jq_ver=$(jq --version)
  echo "  [OK] jq found: $jq_ver"

  # =============================================
  # 2. Core: Validation script
  # =============================================
  print "[2/5] Installing validation script..."
  do_copy \
    "$DEVKIT_DIR/.claude/scripts/validate.sh" \
    "$TARGET/.claude/scripts/validate.sh"

  if [ "$DRY_RUN" = false ]; then
    chmod +x "$TARGET/.claude/scripts/validate.sh"
    INSTALLED+=("validate.sh")
  fi

  # =============================================
  # 3. Commands
  # =============================================
  print "[3/5] Installing commands..."

  do_copy \
    "$DEVKIT_DIR/.claude/commands/validate.md" \
    "$TARGET/.claude/commands/validate.md"
  if [ "$DRY_RUN" = false ]; then
    INSTALLED+=("/validate command")
  fi

  if [ "$FULL" = true ]; then
    do_copy \
      "$DEVKIT_DIR/.claude/commands/generate-file.md" \
      "$TARGET/.claude/commands/generate-file.md"
    if [ "$DRY_RUN" = false ]; then
      INSTALLED+=("/generate-file command")
    fi
  fi

  # =============================================
  # 4. Hooks + Permissions (merge into target's settings.json)
  # =============================================
  print "[4/5] Configuring hooks and permissions..."

  local TARGET_SETTINGS="$TARGET/.claude/settings.json"
  local TARGET_SETTINGS_DIR
  TARGET_SETTINGS_DIR="$(dirname "$TARGET_SETTINGS")"

  if [ "$DRY_RUN" = false ]; then
    mkdir -p "$TARGET_SETTINGS_DIR"
  fi

  if [ "$DRY_RUN" = true ]; then
    echo "  [DRY-RUN] would merge into: $TARGET_SETTINGS"
    echo "  [DRY-RUN] would add permissions:"
    for perm in "${REQUIRED_PERMISSIONS[@]}"; do
      echo "    - $perm"
    done
    echo "  [DRY-RUN] would add hooks.PostToolUse (matcher: Write|Edit)"
  else
    if [ -f "$TARGET_SETTINGS" ]; then
      # Build jq filter: add required permissions + hook
      local perm_array="["
      local first=true
      for perm in "${REQUIRED_PERMISSIONS[@]}"; do
        if [ "$first" = true ]; then
          first=false
        else
          perm_array+=", "
        fi
        perm_array+="\"$perm\""
      done
      perm_array+="]"

      jq \
        --argjson new_perms "$perm_array" \
        '.permissions.allow = ((.permissions.allow // []) + $new_perms | unique)
         | .hooks.PostToolUse = [{"matcher": "Edit", "hooks": [{"type": "command", "if": "Edit(*.claude*)", "command": "bash .claude/scripts/validate.sh", "timeout": 30}]}, {"matcher": "Write", "hooks": [{"type": "command", "if": "Write(*.claude*)", "command": "bash .claude/scripts/validate.sh", "timeout": 30}]}]' \
        "$TARGET_SETTINGS" > "${TARGET_SETTINGS}.tmp" && mv "${TARGET_SETTINGS}.tmp" "$TARGET_SETTINGS"

      echo "  [MERGE] permissions + hooks → $(basename "$TARGET_SETTINGS")"
    else
      # Create new settings.json from scratch
      cat > "$TARGET_SETTINGS" << JSONEOF
{
  "permissions": {
    "allow": [
      "Bash(bash .claude/scripts/validate.sh*)",
      "Bash(jq *)"
    ]
  },
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit",
        "hooks": [
          {
            "type": "command",
            "if": "Edit(*.claude*)",
            "command": "bash .claude/scripts/validate.sh",
            "timeout": 30
          }
        ]
      },
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "if": "Write(*.claude*)",
            "command": "bash .claude/scripts/validate.sh",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
JSONEOF
      echo "  [CREATE] $(basename "$TARGET_SETTINGS")"
    fi
    INSTALLED+=("PostToolUse hook")
    INSTALLED+=("permissions (validate.sh + jq)")
  fi

  # =============================================
  # 5. Optional: Skill + Guides + Templates (--full only)
  # =============================================
  if [ "$FULL" = true ]; then
    print "[5/5] Installing design philosophy skill, guides, and templates..."

    # Design philosophy skill
    do_copy \
      "$DEVKIT_DIR/.claude/skills/design-philosophy/SKILL.md" \
      "$TARGET/.claude/skills/design-philosophy/SKILL.md"
    if [ "$DRY_RUN" = false ]; then
      INSTALLED+=("design-philosophy skill")
    fi

    # Guides
    local guide_count=0
    for guide in "$DEVKIT_DIR"/guides/*.md; do
      do_copy "$guide" "$TARGET/.claude/devkit-guides/$(basename "$guide")"
      guide_count=$((guide_count + 1))
    done
    if [ "$DRY_RUN" = false ] && [ "$guide_count" -gt 0 ]; then
      INSTALLED+=("$guide_count guides")
    fi

    # Templates
    local tmpl_count=0
    for tmpl in "$DEVKIT_DIR"/templates/*; do
      do_copy "$tmpl" "$TARGET/.claude/devkit-templates/$(basename "$tmpl")"
      tmpl_count=$((tmpl_count + 1))
    done
    if [ "$DRY_RUN" = false ] && [ "$tmpl_count" -gt 0 ]; then
      INSTALLED+=("$tmpl_count templates")
    fi

    # Update target's CLAUDE.md to reference the skill
    local TARGET_CLAUDE="$TARGET/.claude/CLAUDE.md"
    if [ "$DRY_RUN" = false ] && [ -f "$TARGET_CLAUDE" ]; then
      if ! grep -q "design-philosophy" "$TARGET_CLAUDE" 2>/dev/null; then
        echo "" >> "$TARGET_CLAUDE"
        echo "## DevKit Integration" >> "$TARGET_CLAUDE"
        echo "This project uses Claude Code DevKit for config file validation." >> "$TARGET_CLAUDE"
        echo "The design philosophy skill is at \`.claude/skills/design-philosophy/SKILL.md\`" >> "$TARGET_CLAUDE"
        echo "  [APPEND] reference in .claude/CLAUDE.md"
        INSTALLED+=("CLAUDE.md reference")
      else
        echo "  [SKIP] .claude/CLAUDE.md already references devkit"
      fi
    fi
  fi

  # =============================================
  # Post-deploy: Validate
  # =============================================
  if [ "$DRY_RUN" = false ] && [ -f "$TARGET/.claude/settings.json" ]; then
    echo ""
    print "Running post-deploy validation..."
    if bash "$TARGET/.claude/scripts/validate.sh" "$TARGET/.claude/settings.json"; then
      print "Post-deploy validation PASSED"
    else
      warn "Post-deploy validation found issues — review output above"
    fi
  fi

  # =============================================
  # Summary
  # =============================================
  echo ""
  print "=== Deployment Complete ==="
  echo ""

  if [ "$DRY_RUN" = true ]; then
    echo "DRY RUN — no files were modified"
    echo ""
  fi

  echo "Installed components:"
  for item in "${INSTALLED[@]}"; do
    echo "  [✓] $item"
  done

  echo ""
  echo "Target project: $TARGET"
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
  echo "  .claude/commands/generate-file.md (if present)"
  echo "  .claude/skills/design-philosophy/ (if present)"
  echo "  .claude/devkit-guides/ (if present)"
  echo "  .claude/devkit-templates/ (if present)"
  echo "  And restore .claude/settings.json to remove hooks and added permissions"
}

run_deploy
