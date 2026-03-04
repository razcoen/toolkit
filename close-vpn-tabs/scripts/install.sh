#!/bin/bash
set -e

INSTALL_DIR="$HOME/close-vpn-tabs"
PLIST_NAME="com.user.closevpntabs.plist"
LAUNCH_AGENTS="$HOME/Library/LaunchAgents"
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DEFAULT_URL="127.0.0.1:35001"

# Check for gum
if ! command -v gum &>/dev/null; then
  echo "Installing gum..."
  brew install gum
fi

# Detect default browser
detect_default_browser() {
  local bundle_id
  bundle_id=$(defaults read com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers 2>/dev/null \
    | grep -B1 '"https"' \
    | grep LSHandlerRoleAll \
    | sed 's/.*= "\(.*\)";/\1/' \
    | head -1)

  case "$bundle_id" in
    com.google.chrome)        echo "Google Chrome" ;;
    com.apple.safari)         echo "Safari" ;;
    com.brave.browser)        echo "Brave Browser" ;;
    com.microsoft.edgemac)    echo "Microsoft Edge" ;;
    company.thebrowser.browser) echo "Arc" ;;
    *)                        echo "Google Chrome" ;;
  esac
}

DEFAULT_BROWSER=$(detect_default_browser)

gum style \
  --border rounded \
  --padding "0 2" \
  --border-foreground 212 \
  "Close VPN Tabs — Installer"

BROWSERS=$(gum choose --no-limit \
  --header "Select browsers to monitor:" \
  --selected "$DEFAULT_BROWSER" \
  "Google Chrome" \
  "Safari" \
  "Brave Browser" \
  "Microsoft Edge" \
  "Arc")

if [ -z "$BROWSERS" ]; then
  echo "No browsers selected. Cancelled."
  exit 1
fi

VPN_URL=$(gum input \
  --placeholder "$DEFAULT_URL" \
  --prompt "VPN auth URL to close: " \
  --value "$DEFAULT_URL")

INTERVAL=$(gum input \
  --placeholder "60" \
  --prompt "Poll interval (seconds): " \
  --value "60")

echo ""
gum style --faint "Browsers: $(echo "$BROWSERS" | tr '\n' ',' | sed 's/,$//' | sed 's/,/, /g')"
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
cp "$SCRIPT_DIR/src/close_vpn_tabs.applescript" "$INSTALL_DIR/"
echo "$VPN_URL" > "$INSTALL_DIR/vpn_url.txt"
echo "$BROWSERS" > "$INSTALL_DIR/browsers.txt"
sed "s|__INSTALL_DIR__|$INSTALL_DIR|g;s|__INTERVAL__|$INTERVAL|g" \
  "$SCRIPT_DIR/src/com.user.closevpntabs.plist.template" > "$LAUNCH_AGENTS/$PLIST_NAME"
launchctl load "$LAUNCH_AGENTS/$PLIST_NAME"

echo ""
gum style \
  --border rounded \
  --padding "0 2" \
  --border-foreground 76 \
  "Installed. Tabs matching $VPN_URL will be closed every ${INTERVAL}s."
