#!/bin/bash
set -e

INSTALL_DIR="$HOME/close-vpn-tabs"
PLIST_NAME="com.user.closevpntabs.plist"
LAUNCH_AGENTS="$HOME/Library/LaunchAgents"
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DEFAULT_URL="127.0.0.1:35001"
DEFAULT_INTERVAL="60"
NON_INTERACTIVE=false

# Check for AWS VPN Client
if [ ! -d "/Applications/AWS VPN Client" ] && [ ! -d "/Applications/AWS VPN Client.app" ]; then
  echo "AWS VPN Client is not installed. Nothing to do."
  exit 1
fi

# Parse flags
while [[ $# -gt 0 ]]; do
  case "$1" in
    --defaults) NON_INTERACTIVE=true; shift ;;
    *) shift ;;
  esac
done

# Detect which supported browsers are installed
INSTALLED_BROWSERS=()
[ -d "/Applications/Google Chrome.app" ] && INSTALLED_BROWSERS+=("Google Chrome")
[ -d "/Applications/Safari.app" ] && INSTALLED_BROWSERS+=("Safari")
[ -d "/Applications/Firefox.app" ] && INSTALLED_BROWSERS+=("Firefox")
[ -d "/Applications/Brave Browser.app" ] && INSTALLED_BROWSERS+=("Brave Browser")
[ -d "/Applications/Microsoft Edge.app" ] && INSTALLED_BROWSERS+=("Microsoft Edge")
[ -d "/Applications/Arc.app" ] && INSTALLED_BROWSERS+=("Arc")

if [ ${#INSTALLED_BROWSERS[@]} -eq 0 ]; then
  echo "No supported browsers found."
  exit 1
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
    com.google.chrome)          echo "Google Chrome" ;;
    com.apple.safari)           echo "Safari" ;;
    org.mozilla.firefox)        echo "Firefox" ;;
    com.brave.browser)          echo "Brave Browser" ;;
    com.microsoft.edgemac)      echo "Microsoft Edge" ;;
    company.thebrowser.browser) echo "Arc" ;;
    *)                          echo "${INSTALLED_BROWSERS[0]}" ;;
  esac
}

DEFAULT_BROWSER=$(detect_default_browser)

if [ "$NON_INTERACTIVE" = true ]; then
  BROWSERS="$DEFAULT_BROWSER"
  VPN_URL="$DEFAULT_URL"
  INTERVAL="$DEFAULT_INTERVAL"
  echo "Installing with defaults: browser=$BROWSERS, url=$VPN_URL, interval=${INTERVAL}s"
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
    "Close VPN Tabs — Installer"

  BROWSERS=$(gum choose --no-limit \
    --header "Select browsers to monitor:" \
    --selected "$DEFAULT_BROWSER" \
    "${INSTALLED_BROWSERS[@]}")

  if [ -z "$BROWSERS" ]; then
    echo "No browsers selected. Cancelled."
    exit 1
  fi
  echo "Browsers: $(echo "$BROWSERS" | tr '\n' ',' | sed 's/,$//' | sed 's/,/, /g')"

  VPN_URL=$(gum input \
    --placeholder "$DEFAULT_URL" \
    --prompt "VPN auth URL to close: " \
    --value "$DEFAULT_URL")
  echo "URL:      $VPN_URL"

  INTERVAL=$(gum input \
    --placeholder "$DEFAULT_INTERVAL" \
    --prompt "Poll interval (seconds): " \
    --value "$DEFAULT_INTERVAL")
  echo "Interval: ${INTERVAL}s"

  echo ""
  if ! gum confirm "Install?"; then
    echo "Cancelled."
    exit 0
  fi
fi

# Unload existing agent
launchctl unload "$LAUNCH_AGENTS/$PLIST_NAME" 2>/dev/null || true

# Install
mkdir -p "$INSTALL_DIR"
cp "$SCRIPT_DIR/src/closevpntabs.applescript" "$INSTALL_DIR/"
echo "$VPN_URL" > "$INSTALL_DIR/vpn_url.txt"
echo "$BROWSERS" > "$INSTALL_DIR/browsers.txt"

# Symlink osascript with a readable name (shows "Close VPN Tabs" in background activity)
ln -sf /usr/bin/osascript "$INSTALL_DIR/Close VPN Tabs"

sed "s|__INSTALL_DIR__|$INSTALL_DIR|g;s|__INTERVAL__|$INTERVAL|g" \
  "$SCRIPT_DIR/src/com.user.closevpntabs.plist.template" > "$LAUNCH_AGENTS/$PLIST_NAME"
launchctl load "$LAUNCH_AGENTS/$PLIST_NAME"

# Trigger automation permission prompt by running the script once
echo "Verifying browser automation access..."
osascript "$INSTALL_DIR/closevpntabs.applescript" 2>&1 || true

echo ""
if [ "$NON_INTERACTIVE" = true ]; then
  echo "Installed. Tabs matching $VPN_URL will be closed every ${INTERVAL}s."
else
  gum style \
    --border rounded \
    --padding "0 2" \
    --border-foreground 76 \
    "Installed. Tabs matching $VPN_URL will be closed every ${INTERVAL}s."
fi
