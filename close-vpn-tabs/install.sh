#!/bin/bash
set -e

INSTALL_DIR="$HOME/close-vpn-tabs"
PLIST_NAME="com.user.closevpntabs.plist"
LAUNCH_AGENTS="$HOME/Library/LaunchAgents"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEFAULT_URL="127.0.0.1:35001"

# Check for gum
if ! command -v gum &>/dev/null; then
  echo "Installing gum..."
  brew install gum
fi

gum style \
  --border rounded \
  --padding "0 2" \
  --border-foreground 212 \
  "Close VPN Tabs — Installer"

VPN_URL=$(gum input \
  --placeholder "$DEFAULT_URL" \
  --prompt "VPN auth URL to close: " \
  --value "$DEFAULT_URL")

INTERVAL=$(gum input \
  --placeholder "60" \
  --prompt "Poll interval (seconds): " \
  --value "60")

gum style --faint "URL:      $VPN_URL"
gum style --faint "Interval: ${INTERVAL}s"
echo ""

if ! gum confirm "Install?"; then
  echo "Cancelled."
  exit 0
fi

# Unload existing agent
launchctl unload "$LAUNCH_AGENTS/$PLIST_NAME" 2>/dev/null || true

# Install
mkdir -p "$INSTALL_DIR"
cp "$SCRIPT_DIR/close_vpn_tabs.applescript" "$INSTALL_DIR/"
echo "$VPN_URL" > "$INSTALL_DIR/vpn_url.txt"
sed "s|__INSTALL_DIR__|$INSTALL_DIR|g;s|__INTERVAL__|$INTERVAL|g" \
  "$SCRIPT_DIR/$PLIST_NAME.template" > "$LAUNCH_AGENTS/$PLIST_NAME"
launchctl load "$LAUNCH_AGENTS/$PLIST_NAME"

echo ""
gum style \
  --border rounded \
  --padding "0 2" \
  --border-foreground 76 \
  "Installed. Tabs matching $VPN_URL will be closed every ${INTERVAL}s."
