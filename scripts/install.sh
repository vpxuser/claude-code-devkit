#!/bin/bash
# claude-code-devkit installer
# Deploy / uninstall devkit components into a target project.
#
# Usage:
#   bash install.sh deploy <devkit-path> [options]
#   bash install.sh uninstall [--keep-config]
#   bash install.sh list
#   bash install.sh --help
#
# Options for deploy:
#   --all           Deploy everything (default)
#   --universal     Deploy only universal rules (4 files)
#   --rules         Deploy all rules (universal + devkit-specific)
#   --skills        Deploy skills only
#   --agents        Deploy agents only
#   --commands      Deploy commands only
#   --output-styles Deploy output styles only
#   --templates     Deploy templates only
#   --scripts       Deploy quality scripts only
#   --configs       Generate config files from templates
#   --hooks         Install git pre-commit hook
#   --claude-hooks  Deploy Claude Code hooks (.claude/hooks/)
#   --references    Deploy references
#   --claudemd      Deploy CLAUDE.md template
#   --dry-run       Show what would be deployed without doing it
#   --force         Overwrite existing files without asking

set -euo pipefail

# ─── Constants ───────────────────────────────────────────────────────────────

MANIFEST_DIR=".claude"
MANIFEST_FILE="$MANIFEST_DIR/.devkit-manifest"
MANIFEST_HEADER="# claude-code-devkit manifest — do not edit manually
# deployed: $(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date +%Y-%m-%dT%H:%M:%SZ)
# version: git"

UNIVERSAL_RULES=(
  "design-thinking.md"
  "progressive-disclosure.md"
  "markdown-output.md"
  "yaml-frontmatter.md"
)

DEVKIT_RULES=(
  "skill-writing.md"
  "agent-writing.md"
  "command-writing.md"
  "reference-writing.md"
  "output-style-writing.md"
  "claude-md-writing.md"
  "workflow-writing.md"
  "hook-writing.md"
  "plugin-writing.md"
  "mcp-writing.md"
  "settings-writing.md"
  "rule-writing.md"
)

# ─── Helpers ─────────────────────────────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info()  { echo -e "${BLUE}ℹ${NC} $*"; }
ok()    { echo -e "${GREEN}✔${NC} $*"; }
warn()  { echo -e "${YELLOW}⚠${NC} $*"; }
err()   { echo -e "${RED}✘${NC} $*" >&2; }
die()   { err "$@"; exit 1; }

usage() {
  cat <<'EOF'
claude-code-devkit installer

USAGE:
  bash install.sh deploy <devkit-path> [options]
  bash install.sh uninstall [--keep-config]
  bash install.sh list
  bash install.sh --help

DEPLOY OPTIONS:
  --all           Deploy everything (default)
  --universal     Deploy only 4 universal rules
  --rules         Deploy all rules (universal + devkit-specific)
  --skills        Deploy skills
  --agents        Deploy agents
  --commands      Deploy commands
  --output-styles Deploy output styles
  --templates     Deploy templates
  --scripts       Deploy quality check scripts
  --configs       Generate config files (package.json, .markdownlint.json, .mcp.json)
  --hooks         Install git pre-commit hook
  --claude-hooks  Deploy Claude Code hooks (.claude/hooks/)
  --references    Deploy references
  --claudemd      Deploy CLAUDE.md
  --dry-run       Show what would be copied, do nothing
  --force         Overwrite without asking

EXAMPLES:
  # Deploy everything into current directory
  bash ~/devkit/scripts/install.sh deploy ~/devkit

  # Deploy only universal rules
  bash ~/devkit/scripts/install.sh deploy ~/devkit --universal

  # Deploy skills + agents, force overwrite
  bash ~/devkit/scripts/install.sh deploy ~/devkit --skills --agents --force

  # Show what's deployed
  bash install.sh list

  # Remove everything (keep config files)
  bash install.sh uninstall --keep-config

  # Remove everything including config files
  bash install.sh uninstall
EOF
  exit 0
}

# Resolve a path to absolute (cross-platform)
resolve_path() {
  local p="$1"
  if command -v realpath >/dev/null 2>&1; then
    realpath "$p"
  elif [[ "$OSTYPE" == msys* || "$OSTYPE" == cygwin* ]]; then
    # Git Bash on Windows
    cd "$p" 2>/dev/null && pwd -W || echo "$p"
  else
    cd "$p" 2>/dev/null && pwd || echo "$p"
  fi
}

# sha256 hash of a file (cross-platform)
file_hash() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | cut -d' ' -f1
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | cut -d' ' -f1
  elif command -v certutil >/dev/null 2>&1; then
    certutil -hashfile "$1" SHA256 2>/dev/null | tail -1 | tr -d ' \r\n'
  else
    echo "nohash"
  fi
}

# Copy a file, creating parent dirs. Returns 0 on success, 1 if skipped.
copy_file() {
  local src="$1" dst="$2" force="${3:-false}" dry_run="${4:-false}"

  if [[ ! -f "$src" ]]; then
    warn "Source not found: $src"
    return 1
  fi

  if [[ -f "$dst" ]] && [[ "$force" != "true" ]]; then
    local src_hash dst_hash
    src_hash=$(file_hash "$src")
    dst_hash=$(file_hash "$dst")
    if [[ "$src_hash" == "$dst_hash" ]]; then
      ok "Already up-to-date: $dst"
      return 0
    fi
    warn "File exists and differs: $dst"
    warn "  Use --force to overwrite, or delete it manually."
    return 1
  fi

  if [[ "$dry_run" == "true" ]]; then
    info "[dry-run] Would copy: $src → $dst"
    return 0
  fi

  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  ok "Deployed: $dst"
}

# Add or update a record in the manifest (deduplicates by path)
manifest_add() {
  local rel_path="$1" src_hash="$2"
  local tmp
  tmp=$(mktemp 2>/dev/null || tempfile)
  # Remove existing entry for this path, keep everything else
  if [[ -f "$MANIFEST_FILE" ]]; then
    grep -v "^${rel_path} " "$MANIFEST_FILE" > "$tmp" 2>/dev/null || true
    mv "$tmp" "$MANIFEST_FILE"
  fi
  echo "$rel_path  $src_hash  $(date +%Y-%m-%d)" >> "$MANIFEST_FILE"
}

# Remove a file if it exists
remove_file() {
  local f="$1" dry_run="${2:-false}"
  if [[ -f "$f" ]]; then
    if [[ "$dry_run" == "true" ]]; then
      info "[dry-run] Would remove: $f"
    else
      rm "$f"
      ok "Removed: $f"
    fi
  fi
}

# Remove empty parent directories up to a limit
cleanup_empty_dirs() {
  local dir="$1" limit="$2"
  while [[ "$dir" != "." && "$dir" != "$limit" && -d "$dir" ]]; do
    if [[ -z "$(ls -A "$dir" 2>/dev/null)" ]]; then
      rmdir "$dir" 2>/dev/null && info "Removed empty dir: $dir" || break
    else
      break
    fi
    dir=$(dirname "$dir")
  done
}

# ─── Deploy ──────────────────────────────────────────────────────────────────

do_deploy() {
  local devkit_path="$1"
  shift

  # Parse options
  local component_selected=false
  local deploy_universal=false
  local deploy_all_rules=false
  local deploy_skills=false
  local deploy_agents=false
  local deploy_commands=false
  local deploy_output_styles=false
  local deploy_templates=false
  local deploy_scripts=false
  local deploy_configs=false
  local deploy_hooks=false
  local deploy_claude_hooks=false
  local deploy_references=false
  local deploy_claudemd=false
  local dry_run=false
  local force=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --universal)     deploy_universal=true; component_selected=true ;;
      --rules)         deploy_all_rules=true; component_selected=true ;;
      --skills)        deploy_skills=true; component_selected=true ;;
      --agents)        deploy_agents=true; component_selected=true ;;
      --commands)      deploy_commands=true; component_selected=true ;;
      --output-styles) deploy_output_styles=true; component_selected=true ;;
      --templates)     deploy_templates=true; component_selected=true ;;
      --scripts)       deploy_scripts=true; component_selected=true ;;
      --configs)       deploy_configs=true; component_selected=true ;;
      --hooks)         deploy_hooks=true; component_selected=true ;;
      --claude-hooks)  deploy_claude_hooks=true; component_selected=true ;;
      --references)    deploy_references=true; component_selected=true ;;
      --claudemd)      deploy_claudemd=true; component_selected=true ;;
      --dry-run)       dry_run=true ;;
      --force)         force=true ;;
      --all)           ;; # default behavior
      *)               die "Unknown option: $1 (use --help)" ;;
    esac
    shift
  done

  # If no component selected, deploy everything
  if [[ "$component_selected" != "true" ]]; then
    deploy_universal=true
    deploy_all_rules=true
    deploy_skills=true
    deploy_agents=true
    deploy_commands=true
    deploy_output_styles=true
    deploy_templates=true
    deploy_scripts=true
    deploy_configs=true
    deploy_hooks=true
    deploy_claude_hooks=true
    deploy_references=true
    deploy_claudemd=true
  fi

  # Validate devkit path
  [[ -d "$devkit_path" ]] || die "Devkit path not found: $devkit_path"
  [[ -d "$devkit_path/.claude" ]] || die "Not a devkit directory (missing .claude/): $devkit_path"

  local abs_devkit
  abs_devkit=$(resolve_path "$devkit_path")

  echo ""
  echo "═══════════════════════════════════════════════════════"
  echo "  claude-code-devkit installer"
  echo "═══════════════════════════════════════════════════════"
  echo ""
  info "Devkit source: $abs_devkit"
  info "Target project: $(pwd)"
  [[ "$dry_run" == "true" ]] && warn "DRY RUN — no files will be modified"
  [[ "$force" == "true" ]]  && warn "FORCE mode — existing files will be overwritten"
  echo ""

  # Initialize manifest (preserve existing entries for non-deployed paths)
  if [[ "$dry_run" != "true" ]]; then
    mkdir -p "$MANIFEST_DIR"
    if [[ ! -f "$MANIFEST_FILE" ]]; then
      echo -e "$MANIFEST_HEADER" > "$MANIFEST_FILE"
    fi
  fi

  local deployed=0 skipped=0

  # ── Universal rules ──
  if [[ "$deploy_universal" == "true" ]]; then
    info "Deploying universal rules..."
    for rule in "${UNIVERSAL_RULES[@]}"; do
      local src="$abs_devkit/.claude/rules/$rule"
      local dst=".claude/rules/$rule"
      if copy_file "$src" "$dst" "$force" "$dry_run"; then
        if [[ "$dry_run" != "true" ]]; then
          manifest_add "$dst" "$(file_hash "$dst")"
          deployed=$((deployed + 1))
        fi
      else
        skipped=$((skipped + 1))
      fi
    done
    echo ""
  fi

  # ── Devkit-specific rules ──
  if [[ "$deploy_all_rules" == "true" ]]; then
    info "Deploying devkit-specific rules..."
    for rule in "${DEVKIT_RULES[@]}"; do
      local src="$abs_devkit/.claude/rules/$rule"
      local dst=".claude/rules/$rule"
      if copy_file "$src" "$dst" "$force" "$dry_run"; then
        if [[ "$dry_run" != "true" ]]; then
          manifest_add "$dst" "$(file_hash "$dst")"
          deployed=$((deployed + 1))
        fi
      else
        skipped=$((skipped + 1))
      fi
    done
    echo ""
  fi

  # ── Skills ──
  if [[ "$deploy_skills" == "true" ]]; then
    info "Deploying skills..."
    for skill_dir in "$abs_devkit"/.claude/skills/*/; do
      [[ -d "$skill_dir" ]] || continue
      local skill_name
      skill_name=$(basename "$skill_dir")
      local src="$skill_dir/SKILL.md"
      local dst=".claude/skills/$skill_name/SKILL.md"
      if copy_file "$src" "$dst" "$force" "$dry_run"; then
        if [[ "$dry_run" != "true" ]]; then
          manifest_add "$dst" "$(file_hash "$dst")"
          deployed=$((deployed + 1))
        fi
      else
        skipped=$((skipped + 1))
      fi
    done
    echo ""
  fi

  # ── Agents ──
  if [[ "$deploy_agents" == "true" ]]; then
    info "Deploying agents..."
    for agent in "$abs_devkit"/.claude/agents/*.md; do
      [[ -f "$agent" ]] || continue
      local basename_agent
      basename_agent=$(basename "$agent")
      local dst=".claude/agents/$basename_agent"
      if copy_file "$agent" "$dst" "$force" "$dry_run"; then
        if [[ "$dry_run" != "true" ]]; then
          manifest_add "$dst" "$(file_hash "$dst")"
          deployed=$((deployed + 1))
        fi
      else
        skipped=$((skipped + 1))
      fi
    done
    echo ""
  fi

  # ── Commands ──
  if [[ "$deploy_commands" == "true" ]]; then
    info "Deploying commands..."
    for cmd in "$abs_devkit"/.claude/commands/*.md; do
      [[ -f "$cmd" ]] || continue
      local basename_cmd
      basename_cmd=$(basename "$cmd")
      local dst=".claude/commands/$basename_cmd"
      if copy_file "$cmd" "$dst" "$force" "$dry_run"; then
        if [[ "$dry_run" != "true" ]]; then
          manifest_add "$dst" "$(file_hash "$dst")"
          deployed=$((deployed + 1))
        fi
      else
        skipped=$((skipped + 1))
      fi
    done
    echo ""
  fi

  # ── Output styles ──
  if [[ "$deploy_output_styles" == "true" ]]; then
    info "Deploying output styles..."
    for style in "$abs_devkit"/.claude/output-styles/*.md; do
      [[ -f "$style" ]] || continue
      local basename_style
      basename_style=$(basename "$style")
      local dst=".claude/output-styles/$basename_style"
      if copy_file "$style" "$dst" "$force" "$dry_run"; then
        if [[ "$dry_run" != "true" ]]; then
          manifest_add "$dst" "$(file_hash "$dst")"
          deployed=$((deployed + 1))
        fi
      else
        skipped=$((skipped + 1))
      fi
    done
    echo ""
  fi

  # ── Templates ──
  if [[ "$deploy_templates" == "true" ]]; then
    info "Deploying templates..."
    for tpl in "$abs_devkit"/templates/*; do
      [[ -f "$tpl" ]] || continue
      local basename_tpl
      basename_tpl=$(basename "$tpl")
      local dst="templates/$basename_tpl"
      if copy_file "$tpl" "$dst" "$force" "$dry_run"; then
        if [[ "$dry_run" != "true" ]]; then
          manifest_add "$dst" "$(file_hash "$dst")"
          deployed=$((deployed + 1))
        fi
      else
        skipped=$((skipped + 1))
      fi
    done
    echo ""
  fi

  # ── Scripts ──
  if [[ "$deploy_scripts" == "true" ]]; then
    info "Deploying quality scripts..."
    for script in "$abs_devkit"/scripts/*.sh; do
      [[ -f "$script" ]] || continue
      local basename_script
      basename_script=$(basename "$script")
      local dst="scripts/$basename_script"
      if copy_file "$script" "$dst" "$force" "$dry_run"; then
        if [[ "$dry_run" != "true" ]]; then
          chmod +x "$dst"
          manifest_add "$dst" "$(file_hash "$dst")"
          deployed=$((deployed + 1))
        fi
      else
        skipped=$((skipped + 1))
      fi
    done
    echo ""
  fi

  # ── References ──
  if [[ "$deploy_references" == "true" ]]; then
    info "Deploying references..."
    for ref in "$abs_devkit"/references/*.md; do
      [[ -f "$ref" ]] || continue
      local basename_ref
      basename_ref=$(basename "$ref")
      local dst="references/$basename_ref"
      if copy_file "$ref" "$dst" "$force" "$dry_run"; then
        if [[ "$dry_run" != "true" ]]; then
          manifest_add "$dst" "$(file_hash "$dst")"
          deployed=$((deployed + 1))
        fi
      else
        skipped=$((skipped + 1))
      fi
    done
    echo ""
  fi

  # ── Config files ──
  if [[ "$deploy_configs" == "true" ]]; then
    info "Generating config files from templates..."

    # .markdownlint.json
    if [[ "$dry_run" != "true" ]]; then
      local md_lint_src="$abs_devkit/templates/.markdownlint.json.template"
      if [[ -f "$md_lint_src" ]]; then
        if [[ -f ".markdownlint.json" && "$force" != "true" ]]; then
          warn "Config exists, skipping: .markdownlint.json (use --force)"
          skipped=$((skipped + 1))
        else
          cp "$md_lint_src" ".markdownlint.json"
          manifest_add ".markdownlint.json" "$(file_hash ".markdownlint.json")"
          ok "Generated: .markdownlint.json"
          deployed=$((deployed + 1))
        fi
      fi

      # .mcp.json (only if not exists)
      local mcp_src="$abs_devkit/templates/.mcp.json.template"
      if [[ -f "$mcp_src" ]]; then
        if [[ -f ".mcp.json" ]]; then
          warn "Config exists, skipping: .mcp.json"
          skipped=$((skipped + 1))
        else
          cp "$mcp_src" ".mcp.json"
          manifest_add ".mcp.json" "$(file_hash ".mcp.json")"
          ok "Generated: .mcp.json (edit placeholders before use)"
          deployed=$((deployed + 1))
        fi
      fi

      # package.json (only if not exists — never overwrite)
      local pkg_src="$abs_devkit/templates/package.json.template"
      if [[ -f "$pkg_src" ]]; then
        if [[ -f "package.json" ]]; then
          warn "Config exists, skipping: package.json"
          skipped=$((skipped + 1))
        else
          cp "$pkg_src" "package.json"
          manifest_add "package.json" "$(file_hash "package.json")"
          ok "Generated: package.json (edit [project-name] and [project description])"
          deployed=$((deployed + 1))
        fi
      fi
    else
      info "[dry-run] Would generate: .markdownlint.json, .mcp.json, package.json (if not exist)"
    fi
    echo ""
  fi

  # ── Hooks ──
  if [[ "$deploy_hooks" == "true" ]]; then
    info "Installing git pre-commit hook..."
    if [[ -d ".git" ]]; then
      if [[ "$dry_run" != "true" ]]; then
        local hook_src="$abs_devkit/scripts/pre-commit.sh"
        if [[ -f "$hook_src" ]]; then
          mkdir -p ".git/hooks"
          cp "$hook_src" ".git/hooks/pre-commit"
          chmod +x ".git/hooks/pre-commit"
          manifest_add ".git/hooks/pre-commit" "$(file_hash ".git/hooks/pre-commit")"
          ok "Installed: .git/hooks/pre-commit"
          deployed=$((deployed + 1))
        else
          warn "Hook source not found: $hook_src"
        fi
      else
        info "[dry-run] Would install: .git/hooks/pre-commit"
      fi
    else
      warn "Not a git repository, skipping hook installation"
    fi
    echo ""
  fi

  # ── Claude Code Hooks ──
  if [[ "$deploy_claude_hooks" == "true" ]]; then
    info "Deploying Claude Code hooks..."
    for hook in "$abs_devkit"/.claude/hooks/*.sh; do
      [[ -f "$hook" ]] || continue
      local basename_hook
      basename_hook=$(basename "$hook")
      local dst=".claude/hooks/$basename_hook"
      if copy_file "$hook" "$dst" "$force" "$dry_run"; then
        if [[ "$dry_run" != "true" ]]; then
          chmod +x "$dst"
          manifest_add "$dst" "$(file_hash "$dst")"
          deployed=$((deployed + 1))
        fi
      else
        skipped=$((skipped + 1))
      fi
    done
    echo ""
  fi

  # ── CLAUDE.md ──
  if [[ "$deploy_claudemd" == "true" ]]; then
    local claudemd_src="$abs_devkit/templates/CLAUDE.md.template"
    if [[ ! -f "$claudemd_src" ]]; then
      # Fall back to the devkit's own CLAUDE.md as reference
      claudemd_src="$abs_devkit/CLAUDE.md"
    fi
    if [[ -f "CLAUDE.md" && "$force" != "true" ]]; then
      warn "CLAUDE.md exists, skipping (use --force to overwrite)"
      skipped=$((skipped + 1))
    else
      if copy_file "$claudemd_src" "CLAUDE.md" "$force" "$dry_run"; then
        if [[ "$dry_run" != "true" ]]; then
          manifest_add "CLAUDE.md" "$(file_hash "CLAUDE.md")"
          deployed=$((deployed + 1))
        fi
      else
        skipped=$((skipped + 1))
      fi
    fi
    echo ""
  fi

  # ── Summary ──
  echo "───────────────────────────────────────────────────────"
  if [[ "$dry_run" == "true" ]]; then
    info "Dry run complete. No files were modified."
  else
    ok "Deploy complete: $deployed file(s) deployed, $skipped skipped."
    echo ""
    info "Manifest: $MANIFEST_FILE"
    info "Next steps:"
    echo "  1. Edit package.json — set project name and description"
    echo "  2. Edit .mcp.json — configure your MCP servers"
    echo "  3. Run 'npm install' to install markdownlint"
    echo "  4. Run 'npm run check:all' to verify"
  fi
  echo ""
}

# ─── Uninstall ───────────────────────────────────────────────────────────────

do_uninstall() {
  local keep_config=false
  [[ "${1:-}" == "--keep-config" ]] && keep_config=true

  if [[ ! -f "$MANIFEST_FILE" ]]; then
    die "No manifest found at $MANIFEST_FILE — nothing to uninstall."
  fi

  echo ""
  echo "═══════════════════════════════════════════════════════"
  echo "  claude-code-devkit uninstall"
  echo "═══════════════════════════════════════════════════════"
  echo ""

  local config_files=(".markdownlint.json" ".mcp.json" "package.json")
  local removed=0 kept=0

  # Read manifest and remove listed files
  while IFS= read -r line; do
    # Skip comments and empty lines
    [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue

    local rel_path
    rel_path=$(echo "$line" | awk '{print $1}')

    # Skip config files if --keep-config
    if [[ "$keep_config" == "true" ]]; then
      local is_config=false
      for cf in "${config_files[@]}"; do
        if [[ "$rel_path" == "$cf" ]]; then
          is_config=true
          break
        fi
      done
      if [[ "$is_config" == "true" ]]; then
        info "Kept (config): $rel_path"
        kept=$((kept + 1))
        continue
      fi
    fi

    remove_file "$rel_path"
    if [[ ! -f "$rel_path" ]]; then
      removed=$((removed + 1))
      # Try to clean up empty parent dirs
      cleanup_empty_dirs "$(dirname "$rel_path")" "."
    fi
  done < "$MANIFEST_FILE"

  # Remove manifest itself
  remove_file "$MANIFEST_FILE"
  removed=$((removed + 1))

  # Try to remove empty .claude/rules if no user rules remain
  if [[ -d ".claude/rules" ]]; then
    if [[ -z "$(ls -A .claude/rules 2>/dev/null)" ]]; then
      rmdir ".claude/rules" 2>/dev/null && info "Removed empty dir: .claude/rules"
    fi
  fi

  # Try to remove empty .claude/hooks if no user hooks remain
  if [[ -d ".claude/hooks" ]]; then
    if [[ -z "$(ls -A .claude/hooks 2>/dev/null)" ]]; then
      rmdir ".claude/hooks" 2>/dev/null && info "Removed empty dir: .claude/hooks"
    fi
  fi

  echo ""
  echo "───────────────────────────────────────────────────────"
  ok "Uninstall complete: $removed file(s) removed, $kept kept."
  if [[ "$keep_config" != "true" ]]; then
    info "Config files (.markdownlint.json, .mcp.json, package.json) were also removed."
    info "Run 'npm uninstall markdownlint markdownlint-cli' if you no longer need them."
  fi
  echo ""
}

# ─── List ────────────────────────────────────────────────────────────────────

do_list() {
  if [[ ! -f "$MANIFEST_FILE" ]]; then
    warn "No manifest found at $MANIFEST_FILE"
    echo ""
    info "Deploy devkit first: bash install.sh deploy <devkit-path>"
    exit 0
  fi

  echo ""
  echo "═══════════════════════════════════════════════════════"
  echo "  claude-code-devkit deployed files"
  echo "═══════════════════════════════════════════════════════"
  echo ""

  local total=0
  while IFS= read -r line; do
    [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
    local rel_path hash deploy_date
    rel_path=$(echo "$line" | awk '{print $1}')
    hash=$(echo "$line" | awk '{print $2}')
    deploy_date=$(echo "$line" | awk '{print $3}')

    if [[ -f "$rel_path" ]]; then
      local current_hash
      current_hash=$(file_hash "$rel_path")
      if [[ "$current_hash" == "$hash" ]]; then
        echo -e "  ${GREEN}✔${NC} $rel_path  ($deploy_date)"
      else
        echo -e "  ${YELLOW}✎${NC} $rel_path  (modified since $deploy_date)"
      fi
    else
      echo -e "  ${RED}✘${NC} $rel_path  (MISSING)"
    fi
    total=$((total + 1))
  done < "$MANIFEST_FILE"

  echo ""
  info "Total: $total file(s)"
  echo ""
}

# ─── Main ────────────────────────────────────────────────────────────────────

case "${1:-}" in
  deploy)
    [[ -z "${2:-}" ]] && die "Missing devkit path. Usage: bash install.sh deploy <devkit-path> [options]"
    do_deploy "${@:2}"
    ;;
  uninstall)
    shift
    do_uninstall "${1:-}"
    ;;
  list)
    do_list
    ;;
  --help|-h|help)
    usage
    ;;
  *)
    err "Unknown command: ${1:-<none>}"
    echo ""
    usage
    ;;
esac
