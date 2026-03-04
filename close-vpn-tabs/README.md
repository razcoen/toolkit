# close-vpn-tabs

Automatically closes Chrome tabs opened by AWS VPN Client's browser-based SAML authentication (`127.0.0.1:35001`).

When the VPN reconnects (e.g. after waking from sleep), it can open dozens of auth tabs. This tool polls and closes them.

## Install

```sh
./install.sh
```

The installer prompts for the VPN auth URL and poll interval.

## Uninstall

```sh
./uninstall.sh
```

## Requirements

- macOS
- Google Chrome
- [gum](https://github.com/charmbracelet/gum) (installed automatically if missing)
- Terminal automation access to Chrome: **System Settings → Privacy & Security → Automation**
