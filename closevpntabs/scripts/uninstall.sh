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

if [ "$NON_INTERACTIVE" = false ]; then
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

launchctl unload "$LAUNCH_AGENTS/$PLIST_NAME" 2>/dev/null || true
rm -f "$LAUNCH_AGENTS/$PLIST_NAME"
rm -rf "$INSTALL_DIR"

echo ""
if [ "$NON_INTERACTIVE" = true ]; then
  echo "Uninstalled."
else
  gum style \
    --border rounded \
    --padding "0 2" \
    --border-foreground 76 \
    "Uninstalled."
fi
