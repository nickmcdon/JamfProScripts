#!/bin/sh

# 02/21/18 Created by Nicholas McDonald #
# The purpose of this script is to determine how long a computer has been up and to compare that number against
# the maximum allowed days and to prompt the user to restart if they are above the max number of days
#
# Set the following parameter labels in the script 
#
# Parameter 4 = Logo URL path 
# Parameter 5 = Max allowed days before restart
# Parameter 6 = jamfHelper window title 
# 
# Create a policy that is ongoing weekley and add the script, Fill the paremeter fields like so
#
# Logo URL Path : Put the FULL path to your hosted ICSN file here https://example.com/logo.icns 
#
# Max allowed days before restart : Put the maximum number of days before a restart is waranted in your 
# enviornment here (Must put a whole number) i.e. 6
#
# jamfHelper window title : Put what you would like the "title" of your jamfHelper window to be her i.e. 
# "Technology Department - Important Alert"

#Set the url to curl a ICNS file from
logourl="$4"

#Sets max day through jamf 
maxDays=$5

# Checking if computer has been up for at least a day, then determines how many days. 
DAYS="days,"

DAYScheck=$(uptime | awk {'print $4'})
num=`uptime | awk '{ print $3 }'`

if [ $DAYScheck = "$DAYS" ] && [ $num -gt $maxDays ]; then

	echo "Mac uptime is $num $days" 
		
	#This pulls down the corporate logo
	/usr/bin/curl -s -o /tmp/logo.icns $logourl

	#This gives time for the logo to fully download 
	sleep 2	

	title="$6"
	dialog="
Important Message, Please Read 

Your Mac has not been restarted in $num days, We suggest restarting your mac every $maxDays days.

**** PLEASE SAVE ALL WORK BEFORE SELECTING RESTART ****"
	description=`echo "$dialog"`
	button1="Restart"
	button2="Later"
	jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
	icon="/tmp/logo.icns"
	defaultButton="1"

		userChoice=$("$jamfHelper" -message "$dialog" -windowType utility -description "$description" -button1 "$button1" -button2 "$button2" -icon "$icon" -title "$title" -defaultButton "$defaultButton")


	# If user selects "Restart"
	if [ "$userChoice" == "0" ]; then
		echo "User clicked Restart; now restarting hard"
		# Initiates a hard restart
		shutdown -r now
	# If user selects "Later"
	elif [ "$userChoice" == "2" ]; then
		echo "User clicked I'll restart later or timeout was reached; now exiting."   
	fi
	
else		
	echo "Device has been restarted within in $maxDays days."
	exit 0 
fi 

exit 0