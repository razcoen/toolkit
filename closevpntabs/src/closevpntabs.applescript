-- Close all tabs matching the VPN auth URL across selected browsers

set vpnUrl to "__VPN_URL__"
set browserList to "__BROWSERS__"

repeat with browserLine in paragraphs of browserList
	set browserName to browserLine as text
	if browserName is "" then
		-- skip empty lines
	else if browserName is "Safari" then
		tell application "Safari"
			if it is running then
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
			end if
		end tell
	else if browserName is "Firefox" then
		tell application "Firefox"
			if it is running then
				tell application "System Events"
					tell process "firefox"
						set windowList to every window
						repeat with w in windowList
							if name of w contains vpnUrl then
								perform action "AXRaise" of w
								keystroke "w" using command down
							end if
						end repeat
					end tell
				end tell
			end if
		end tell
	else
		-- Chromium-based browsers (Chrome, Brave, Edge, Arc)
		using terms from application "Google Chrome"
			tell application browserName
				if it is running then
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
				end if
			end tell
		end using terms from
	end if
end repeat
