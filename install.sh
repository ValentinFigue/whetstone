#!/bin/bash
set -e

MODE=${1:-local}

if [ "$MODE" = "global" ]; then
  TARGET="$HOME/.claude/commands"
else
  TARGET=".claude/commands"
fi

mkdir -p "$TARGET"

curl -fsSL \
  -o "$TARGET/autocritic.md" \
  "https://raw.githubusercontent.com/ValentinFigue/whetstone/main/.claude/commands/autocritic.md"

echo "✓ /autocritic installed to $TARGET"

if [ "$MODE" = "global" ]; then
  echo "  Available in all Claude Code projects."
else
  echo "  Available in this project. Restart Claude Code to activate."
  echo ""
  echo "  Tip: for global install, run: bash install.sh global"
fi
