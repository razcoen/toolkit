-- Close all tabs matching the configured VPN auth URL in Chrome

set vpnUrl to do shell script "cat \"$HOME/close-vpn-tabs/vpn_url.txt\" 2>/dev/null || echo '127.0.0.1:35001'"

tell application "Google Chrome"
	repeat with w in windows
		set tabsToClose to {}
		repeat with t in tabs of w
			if URL of t contains vpnUrl then
				set end of tabsToClose to t
			end if
		end repeat
		repeat with t in tabsToClose
			close t
		end repeat
	end repeat
end tell
