#!/bin/bash
exec 2> /dev/null

user=$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

mountscript=$(sudo -u $user /usr/bin/osascript<<END
tell application "Finder"
	mount volume "smb://domain.dom/drived"
end tell
END)

exit 0