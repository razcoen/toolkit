-- Close all AWS VPN auth tabs in Chrome

tell application "Google Chrome"
	repeat with w in windows
		set tabsToClose to {}
		repeat with t in tabs of w
			if URL of t contains "127.0.0.1:35001" then
				set end of tabsToClose to t
			end if
		end repeat
		repeat with t in tabsToClose
			close t
		end repeat
	end repeat
end tell
