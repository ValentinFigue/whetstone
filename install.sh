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
  CLAUDE_FILE="$HOME/.claude/CLAUDE.md"
else
  COMMANDS_DIR=".claude/commands"
  CLAUDE_FILE="./CLAUDE.md"
fi

# Install command file
mkdir -p "$COMMANDS_DIR"
curl -fsSL \
  -o "$COMMANDS_DIR/autocritic.md" \
  "https://raw.githubusercontent.com/ValentinFigue/whetstone/main/.claude/commands/autocritic.md"
echo "✓ /autocritic installed to $COMMANDS_DIR"

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

echo ""
if [ "$MODE" = "global" ]; then
  echo "Available in all Claude Code projects. Restart Claude Code to activate."
else
  echo "Available in this project. Restart Claude Code to activate."
  echo ""
  echo "Tips:"
  echo "  Global install:             bash install.sh global"
  echo "  With auto-trigger:          bash install.sh --claude-md"
  echo "  Global + auto-trigger:      bash install.sh global --claude-md"
fi
