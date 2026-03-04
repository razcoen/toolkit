# closevpntabs

Automatically closes browser tabs opened by AWS VPN Client's browser-based SAML authentication (`127.0.0.1:35001`).

When the VPN reconnects (e.g. after waking from sleep), it can open dozens of auth tabs. This tool polls every 60 seconds and closes them.

## Install

Interactive (with [gum](https://github.com/charmbracelet/gum) TUI):

```sh
make install
```

Non-interactive (uses defaults):

```sh
make install ARGS="--defaults"
```

The installer will:
- Check that AWS VPN Client is installed
- Detect installed browsers and your default browser
- Prompt for VPN auth URL and poll interval (or use defaults)
- Template and install the script to `~/.closevpntabs/`
- Load a launchd agent that runs on login
- Verify browser automation access

## Uninstall

```sh
make uninstall
```

## Supported browsers

- Google Chrome
- Safari
- Firefox
- Brave
- Microsoft Edge
- Arc

Only browsers installed on your machine are shown during setup.

## Requirements

- macOS
- AWS VPN Client
- [gum](https://github.com/charmbracelet/gum) (installed automatically if missing, not needed with `--defaults`)
