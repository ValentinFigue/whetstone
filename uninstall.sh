#!/bin/bash
set -e

MODE="local"
CLEAN_CLAUDE_MD=false

for arg in "$@"; do
  case "$arg" in
    global) MODE="global" ;;
    --claude-md) CLEAN_CLAUDE_MD=true ;;
  esac
done

if [ "$MODE" = "global" ]; then
  COMMANDS_DIR="$HOME/.claude/commands"
  CLAUDE_FILE="$HOME/.claude/CLAUDE.md"
else
  COMMANDS_DIR=".claude/commands"
  CLAUDE_FILE="./CLAUDE.md"
fi

REMOVED=0

# Remove command file
COMMAND_FILE="$COMMANDS_DIR/autocritic.md"
if [ -f "$COMMAND_FILE" ]; then
  rm "$COMMAND_FILE"
  echo "✓ Removed $COMMAND_FILE"
  REMOVED=$((REMOVED + 1))
else
  echo "  $COMMAND_FILE not found — skipped"
fi

# Remove whetstone section from CLAUDE.md
if [ "$CLEAN_CLAUDE_MD" = true ]; then
  if [ -f "$CLAUDE_FILE" ] && grep -q "<!-- whetstone:start -->" "$CLAUDE_FILE"; then
    awk '/<!-- whetstone:start -->/{skip=1} !skip{print} /<!-- whetstone:end -->/{skip=0}' \
      "$CLAUDE_FILE" > "$CLAUDE_FILE.tmp" && mv "$CLAUDE_FILE.tmp" "$CLAUDE_FILE"
    echo "✓ Removed whetstone section from $CLAUDE_FILE"
    REMOVED=$((REMOVED + 1))
  else
    echo "  No whetstone section found in $CLAUDE_FILE — skipped"
  fi
fi

echo ""
if [ "$REMOVED" -gt 0 ]; then
  echo "Done. Restart Claude Code to apply changes."
else
  echo "Nothing to remove."
fi
