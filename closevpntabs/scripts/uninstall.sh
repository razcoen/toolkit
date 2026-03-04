#!/bin/bash
set -e

INSTALL_DIR="$HOME/close-vpn-tabs"
PLIST_NAME="com.user.closevpntabs.plist"
LAUNCH_AGENTS="$HOME/Library/LaunchAgents"
NON_INTERACTIVE=false

# Parse flags
while [[ $# -gt 0 ]]; do
  case "$1" in
    --defaults) NON_INTERACTIVE=true; shift ;;
    *) shift ;;
  esac
done

if [ "$NON_INTERACTIVE" = true ]; then
  echo "Close VPN Tabs — Uninstaller"
else
  # Check for gum
  if ! command -v gum &>/dev/null; then
    echo "Installing gum..."
    brew install gum
  fi

  gum style \
    --border rounded \
    --padding "0 2" \
    --border-foreground 212 \
    "Close VPN Tabs — Uninstaller"

  if ! gum confirm "Uninstall close-vpn-tabs?"; then
    echo "Cancelled."
    exit 0
  fi
fi

echo ""

if launchctl list | grep -q com.user.closevpntabs; then
  launchctl unload "$LAUNCH_AGENTS/$PLIST_NAME" 2>/dev/null || true
  echo "✔ Unloaded launchd agent"
else
  echo "– Launchd agent not loaded (skipped)"
fi

if [ -f "$LAUNCH_AGENTS/$PLIST_NAME" ]; then
  rm -f "$LAUNCH_AGENTS/$PLIST_NAME"
  echo "✔ Removed $LAUNCH_AGENTS/$PLIST_NAME"
else
  echo "– $PLIST_NAME not found (skipped)"
fi

if [ -d "$INSTALL_DIR" ]; then
  rm -rf "$INSTALL_DIR"
  echo "✔ Removed $INSTALL_DIR"
else
  echo "– $INSTALL_DIR not found (skipped)"
fi

echo ""
echo "Done."
