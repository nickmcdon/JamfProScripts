#!/bin/sh

# 08/10/18 Created by Nicholas McDonald
#
# The purpose of this script is to prompt end users once per week to accept the AUP 
# 
# Create a policy that is ongoing weekly/monthly and add this script. Set other options as needed.
#

#Set the label of parameter 5 to "Blocking Apps" inside of Jamf, Inside of your policy set the value of "Blocking Apps" to your app name such as "Safari" with no ".app", You can include multiple apps by separating each with a space i.e. "Safari Keynote Pages Word" The script will check sequentially for each app, if it detects an app as being open the script will exit silently, and echo out the offending app. 
apps="${4}"
#Set the label of parameter 5 to "AUP Title", Inside of your policy set the value of "AUP Title" to whatever you would like the window title to be. 
title="${5}"
#Set the label of parameter 6 to "Button Text", Inside of your policy set the value of "Button Text" to whatever you would like the button text to be, i.e. "Accept" 
button1="${6}"
#Put your full AUP in-between the quotes below. This is not specified through a parameter due to length restrictions in Jamf Pro   
dialog="PUT AUP HERE"
#Encode your organization's logo into Base64 text and paste it in between the two quotes below. You can do this via terminal by running the following command " cat /path/to/image.png | base64 ", copy the output. 
logo="Paste Base64 encoded image here"

description=`echo "${dialog}"`
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
icon="/tmp/icn.png"
defaultButton="1"

user=$(stat -f%Su /dev/console)

base64 -D <<< "${logo}" > "/tmp/icn.png"


fPrompt ()
{
		userChoice=$("${jamfHelper}" -message "${dialog}" -windowType utility -description "${description}" -button1 "${button1}" -icon "${icon}" -title "${title}" -defaultButton "${defaultButton}")	
		if [ "$userChoice" == "0" ]; then
			echo "$user has accepted the AUP"
			exit 0
		else		
			echo "Script timed out or user killed jamfHelper"
			exit 0 
		fi 
}

fCheckApps ()
{
	for app in $apps
	do		
		if pgrep -x "$app" > /dev/null 
		then		
		echo "Cannot display AUP due to ${app}"
		exit 0
		else		
		echo "${app} not running"
		fi
	done	
	
	fPrompt
}

fCheckUser ()
{	
	if [[ ${user} == "root" ]]
	then	
	echo "No User logged in, exiting"
	exit 0
	else	
	echo "User: ${user} logged in, now checking apps"

	fCheckApps
	fi	
}

fCheckUser

exit 1
