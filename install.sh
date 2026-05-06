#!/bin/bash
set -e

MODE="local"
WITH_CLAUDE_MD=false

for arg in "$@"; do
  case "$arg" in
    global) MODE="global" ;;
    --claude-md) WITH_CLAUDE_MD=true ;;
  esac
done

if [ "$MODE" = "global" ]; then
  COMMANDS_DIR="$HOME/.claude/commands"
  SETTINGS_DIR="$HOME/.claude"
  CLAUDE_FILE="$HOME/.claude/CLAUDE.md"
else
  COMMANDS_DIR=".claude/commands"
  SETTINGS_DIR=".claude"
  CLAUDE_FILE="./CLAUDE.md"
fi

_json_add_perms() {
  local file="$1"
  if command -v python3 &>/dev/null; then
    python3 - "$file" <<'PYEOF'
import json, sys
f = sys.argv[1]
with open(f) as fh: s = json.load(fh)
allow = s.setdefault("permissions", {}).setdefault("allow", [])
for p in ["Read", "Write"]:
    if p not in allow: allow.append(p)
print(json.dumps(s, indent=2))
PYEOF
  elif command -v node &>/dev/null; then
    node - "$file" <<'JSEOF'
const f = process.argv[2];
const s = JSON.parse(require("fs").readFileSync(f, "utf8"));
s.permissions = s.permissions || {};
s.permissions.allow = s.permissions.allow || [];
for (const p of ["Read", "Write"]) { if (!s.permissions.allow.includes(p)) s.permissions.allow.push(p); }
process.stdout.write(JSON.stringify(s, null, 2) + "\n");
JSEOF
  elif command -v jq &>/dev/null; then
    jq '.permissions.allow |= (. + ["Read","Write"] | unique)' "$file"
  else
    return 1
  fi
}

# Install command file
mkdir -p "$COMMANDS_DIR"
curl -fsSL \
  -o "$COMMANDS_DIR/autocritic.md" \
  "https://raw.githubusercontent.com/ValentinFigue/whetstone/main/.claude/commands/autocritic.md"
echo "✓ /autocritic installed to $COMMANDS_DIR"

# Inject Read + Write permissions into settings.json
SETTINGS_FILE="$SETTINGS_DIR/settings.json"
mkdir -p "$SETTINGS_DIR"
if [ ! -f "$SETTINGS_FILE" ]; then
  printf '{\n  "permissions": {\n    "allow": ["Read", "Write"]\n  }\n}\n' > "$SETTINGS_FILE"
  echo "✓ Permissions (Read, Write) added to $SETTINGS_FILE"
elif _json_add_perms "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"; then
  echo "✓ Permissions (Read, Write) added to $SETTINGS_FILE"
else
  echo "  Could not update $SETTINGS_FILE automatically (install python3, node, or jq)."
  echo "  Add \"Read\" and \"Write\" to permissions.allow manually."
fi

# Optionally inject planning discipline into CLAUDE.md
if [ "$WITH_CLAUDE_MD" = true ]; then
  MARKER="<!-- whetstone:start -->"

  if [ -f "$CLAUDE_FILE" ] && grep -q "$MARKER" "$CLAUDE_FILE"; then
    echo "✓ $CLAUDE_FILE already contains whetstone section — skipped"
  else
    TEMPLATE=$(curl -fsSL \
      "https://raw.githubusercontent.com/ValentinFigue/whetstone/main/templates/CLAUDE.md")
    {
      printf "\n"
      echo "<!-- whetstone:start -->"
      echo "$TEMPLATE"
      echo "<!-- whetstone:end -->"
    } >> "$CLAUDE_FILE"
    echo "✓ Planning discipline added to $CLAUDE_FILE"
  fi
fi

# Install whetstone CLI for global mode
if [ "$MODE" = "global" ]; then
  CLI_DIR="$HOME/.local/bin"
  mkdir -p "$CLI_DIR"
  curl -fsSL \
    -o "$CLI_DIR/whetstone" \
    "https://raw.githubusercontent.com/ValentinFigue/whetstone/main/bin/whetstone"
  chmod +x "$CLI_DIR/whetstone"
  echo "✓ whetstone CLI installed to $CLI_DIR/whetstone"

  if ! echo "$PATH" | grep -q "$CLI_DIR"; then
    echo "  Note: add $CLI_DIR to your PATH to use the 'whetstone' command"
  fi
fi

echo ""
if [ "$MODE" = "global" ]; then
  echo "Available in all Claude Code projects. Restart Claude Code to activate."
  echo ""
  echo "Run 'whetstone status' to verify your install."
else
  echo "Available in this project. Restart Claude Code to activate."
  echo ""
  echo "Tips:"
  echo "  Global install:             bash install.sh global"
  echo "  With auto-trigger:          bash install.sh --claude-md"
  echo "  Global + auto-trigger:      bash install.sh global --claude-md"
fi
