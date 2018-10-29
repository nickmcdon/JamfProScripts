#!/bin/bash

# Nicholas McDonald 
# Created on 04/09/18 Updated 09/11/18
# This script is desinged to walk an end user through the process of enabling lost mode on an iOS device.
# Script Version 2.0 - See change logs for details 


##### Set variables below this line  ######

#Set the label of parameter 4 to "API User" - Set the parameter as the API User 
apiuser="${4}"
#Set the label of parameter 5 to "API Password" - Set the parameter as the API Password 
apipass="${5}"
#Set the label of parameter 6 to "Jamf Pro URL" - Put the url of your Jamf Pro url (include only https://jamf.pizza.com) any forward slash after the domain will break the script
jssurl="${6}"
#Set the label of parameter 7 to "Orgnaization Name" - Set the parameter to the organizational name followed by IT Dept i.e. "Pizza Co. - IT Dept".
orgname="${7}"
#Set the label of parameter 8 to "Lost Mode Message" - Set the parameter to your lost mode message, please note that the device serial number + asset tag will be added to the end of your messsage 
lostmodemessage="${8}"
#Set the label of parameter 9 to "Phone Number" - Set the parameter to your lost mode phone number, this is the phone number that will display on the lost mode screen
phonenum="${9}"
#Sets the label of parameter 10 to "User Lookup diagloge" - Set the parameter to show diaglos when a user choses to search by "Username" something along the lines of "Enter an Active Directory Username"
userlookupdiag="${10}"

osatimeout="800"
osagiveup="500"

###### End set variables #######

#This checks the serial number of the device running the script and echos it out into the log, this is for auditing purposes
loggedserial=$(ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}')
loggedresponse=$(curl -H "Accept: text/xml" -sfk ${jssurl}/JSSResource/computers/serialnumber/${loggedserial}/subset/location --user "${apiuser}:${apipass}")
jpsloggeduser=$(echo $loggedresponse | /usr/bin/awk -F'<real_name>|</real_name>' '{print $2}');

echo ${jpsloggeduser} "Has initiated a lost mode request"
echo ${loggedserial} "Has initiated a lost mode request"

#This sets up the FMI Logo
fmilogo="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
"
base64 -D <<< "${fmilogo}" > "/tmp/fmi.png"


####### Functions below this line #########

fSearchOptions ()
{
	USERCHOICE=$(/usr/bin/osascript<<END
	with timeout of ${osatimeout} seconds
	tell application "Self Service"
	activate
	set the answer to button returned of (display dialog "Please select how you would like to search for the device. \n\nUniversal search will allow you to search for devices based off of any hardware identified. i.e. Asset Tag/Serial Number/Device Name." with title "Lost Mode - ${orgname}" buttons {"Close", "Username", "Universal"} default button 3 giving up after ${osagiveup})
	end tell
	end timeout
END)

	#Opening if for userchoice
	if [[ "${USERCHOICE}" = "Username" ]]; then
		echo "${jpsloggeduser} selected ${USERCHOICE}"
		fUserNameInput	
		
	elif [[ "${USERCHOICE}" = "Universal" ]]; then
		echo "${jpsloggeduser} selected ${USERCHOICE}"
		fUniversalInput
		
	elif [[ "${USERCHOICE}" = "Close" ]]; then
		echo "${jpsloggeduser} selected ${USERCHOICE}"
		fCloseLostMode
		
	#Else for userchoice 	
	else	
	    echo "An applescript timeout occured at Universal Input" 
		ERROR="An AppleScript timeout has occured please try again." fErrorMessage

	#Fi for userchoice
	fi 
	
}

fErrorMessage ()
{
errorwindow=$(/usr/bin/osascript<<END
tell application "Self Service"
activate
set the answer to button returned of (display dialog "!ERROR!- ${ERROR}" with title "Lost Mode Error" buttons {"Close"})
end tell 
END)&
sleep 2

fCloseLostMode
}

fUserNameInput ()
{
	USERNAMEINPUT=$(/usr/bin/osascript<<END
	with timeout of ${osatimeout} seconds
	tell application "Self Service"
	activate
	display dialog "${userlookupdiag}" buttons {"Close", "Search"} default answer "" default button 2 with title "Lost Mode - ${orgname}" giving up after ${osagiveup}
	copy the result as list to {text_returned, button_pressed}
	end tell
	end timeout
END)
username_button_returned=$(echo "$USERNAMEINPUT" | awk -F, '{ print $1 }')
username_text_returned=$(echo "$USERNAMEINPUT" | awk -F, '{ print $2 }' | xargs echo -n) 

	#Opening IF for username input
	if [[ "${username_button_returned}" = "" ]]; then
	    echo "An applescript timeout occured at Username Input" 
		ERROR="An AppleScript timeout has occured please try again." fErrorMessage
		
	elif [[ "${username_button_returned}" = "Close" ]]; then
	    echo "${jpsloggeduser} closed Lost Mode" 
		fCloseLostMode
		
	elif [[ "${username_text_returned}" != "" ]]; then
		echo "${jpsloggeduser} supplied username ${username_text_returned}" 
		fUserLookup	
	else 
    echo "User left username field blank." 
	ERROR="You have left the username field empty, you must provide a username." fErrorMessage

	#Closing FI for username input 
	fi

}

fUserLookup ()
{
	realname=$(curl -H "Accept: text/xml" -su "${apiuser}:${apipass}" "${jssurl}/JSSResource/users/name/${username_text_returned}" | xpath /user/full_name 2>/dev/null | awk -F'>|<' '{print $3}')
	if [[ "${realname}" != "" ]]; then
	fUserDeviceLookup
	else	
	echo "Username provided does not exist in the Jamf Pro Server"
	ERROR="The entered username does not exist in the Jamf Pro Server" fErrorMessage
	fi
}

fUniversalInput ()
{
	UNIVERSALINPUT=$(/usr/bin/osascript<<END
	with timeout of ${osatimeout} seconds
			tell application "Self Service"
				activate
				display dialog "Please enter a hardware idenitfier for an iOS device, such as a Serial Number, Asset Tag or Device Name.\n You may enter a partial serial number." buttons {"Close", "Search"} default answer "" default button 2 with title "Lost Mode - ${orgname}" giving up after ${osagiveup}
				copy the result as list to {text_returned, button_pressed}
			end tell
	end timeout
END)

universal_button_returned=$(echo "$UNIVERSALINPUT" | awk -F, '{ print $1 }')
universal_text_returned=$(echo "$UNIVERSALINPUT" | awk -F, '{ print $2 }' | xargs echo -n)

	#Opening IF for Universal input
	if [[ "${universal_button_returned}" = "" ]]; then
	    echo "An applescript timeout occured at Universal Input" 
		ERROR="An AppleScript timeout has occured please try again." fErrorMessage
	elif [[ "${universal_button_returned}" = "Close" ]]; then
		echo "${jpsloggeduser} closed Lost Mode" 
		fCloseLostMode
	elif [[ "${universal_text_returned}" != "" ]]; then
		echo "${jpsloggeduser} supplied indentifier ${universal_text_returned}" 
		fUniversalCheck	
	elif [[ "${universal_text_returned}" = "" ]]; then
		echo "User left Universal Search field blank." 
		ERROR="You have left the Universal Search field empty, you must provide a hardware indetifier such as a serial number or asset tag." fErrorMessage
	else 
	    echo "An applescript timeout occured at Universal Input" 
		ERROR="An AppleScript timeout has occured please try again." fErrorMessage

	#Closing FI for Universal input 
	fi
}

fUniversalCheck ()
{
	universallookup=$(curl -H "Accept: text/xml" -sfku "${apiuser}:${apipass}" "${jssurl}/JSSResource/mobiledevices/match/${universal_text_returned}*" | xpath /mobile_devices/mobile_device/id 2>/dev/null)
	
	#Opening IF for Asset Check
	if [[ "${universallookup}" != "" ]]; then
		echo "Universal search HAS returned data" 
		fUniversalLookup	
		
	else 
    echo "No results from Universal search" 
	ERROR="The Jamf Pro Server returned no results for the entered hardware identifier." fErrorMessage

	#Closing FI for Asset Check 
	fi
}

fUniversalLookup ()
{
	jssids=$(echo "${universallookup}" | sed 's$</id>$ $g' | sed 's$<id>$$g'| sed 's/.\{1\}$//')

	rawchoices=$(for id in ${jssids[*]}

	do
		rawdevdata=$(curl -H "Accept: text/xml" -sfku "${apiuser}:${apipass}" "${jssurl}/JSSResource/mobiledevices/id/${id}")
		serial=$(echo "${rawdevdata}" | xpath /mobile_device/general/serial_number[1] 2>/dev/null | awk -F'>|<' '{print $3}')
		lostmodeenabled=$(echo "${rawdevdata}" | xpath /mobile_device/security/lost_mode_enabled[1] 2>/dev/null | awk -F'>|<' '{print $3}')
		invupdate=$(echo "${rawdevdata}" | xpath /mobile_device/general/last_inventory_update[1] 2>/dev/null | awk -F'>|<' '{print $3}')
		jsstag=$(echo "${rawdevdata}" | xpath /mobile_device/general/asset_tag[1] 2>/dev/null | awk -F'>|<' '{print $3}')
		username=$(echo "${rawdevdata}" | xpath /mobile_device/location/username[1] 2>/dev/null | awk -F'>|<' '{print $3}')


		echo "*Tag: ${jsstag}, User: ${username}, Serial: ${serial}, Last Update: ${invupdate}, LM Status: ${lostmodeenabled}#"
		done)

		choices=$(echo "$rawchoices" | sed 's$*$"$g' | sed 's$#$",$g' | sed '$ s/.$//' | tr -dc '[:print:]')

			deviceselection=$(/usr/bin/osascript<<END
				choose from list {$choices} with title "Devices matching ${universal_text_returned}" with prompt "Please select a device below. Once you select a device you will be presented with further information." OK button name "Continue" cancel button name "Close"
END)

	selectedserial=$(echo "$deviceselection" | sed -e 's/.*Serial: \(.*\), Last.*/\1/')
	echo $selectedserial
	
	#Opening IF for Universal lookup
	if [[ "${selectedserial}" = "false" ]]; then
	echo "${jpsloggeduser} has selected Close"
	fCloseLostMode
		
	elif [[ "${selectedserial}" != "" ]]; then
		echo "${jpsloggeduser} has selected ${selectedserial}" 
		fDeviceInfo		
	else 
    echo "An applescript timeout occured at asset tag lookup selection" 
	ERROR="An AppleScript timeout has occured please try again." fErrorMessage

	#Closing FI for Asset input 
	fi

}

fUserDeviceLookup ()
{
    devices=$(curl -H -w '%{http_code}' "Accept: text/xml" -su "${apiuser}:${apipass}" "${jssurl}/JSSResource/users/name/${username_text_returned}" | xpath /user/links/mobile_devices/mobile_device/id 2>/dev/null)

	jssids=$(echo "$devices" | sed 's$</id>$ $g' | sed 's$<id>$$g'| sed 's/.\{1\}$//')

	rawchoices=$(for id in ${jssids[*]}

	do
	rawdevdata=$(curl -H "Accept: text/xml" -sfku "${apiuser}:${apipass}" "${jssurl}/JSSResource/mobiledevices/id/${id}")
	serial=$(echo "${rawdevdata}" | xpath /mobile_device/general/serial_number[1] 2>/dev/null | awk -F'>|<' '{print $3}')
	lostmodeenabled=$(echo "${rawdevdata}" | xpath /mobile_device/security/lost_mode_enabled[1] 2>/dev/null | awk -F'>|<' '{print $3}')
	invupdate=$(echo "${rawdevdata}" | xpath /mobile_device/general/last_inventory_update[1] 2>/dev/null | awk -F'>|<' '{print $3}')
	jsstag=$(echo "${rawdevdata}" | xpath /mobile_device/general/asset_tag[1] 2>/dev/null | awk -F'>|<' '{print $3}')

	echo "*Tag: ${jsstag}, Serial: ${serial}, Last Update: ${invupdate}, LM Status: ${lostmodeenabled}#"
	done)

	choices=$(echo "$rawchoices" | sed 's$*$"$g' | sed 's$#$",$g' | sed '$ s/.$//' | tr -dc '[:print:]')

	deviceselection=$(/usr/bin/osascript<<END
	with timeout of 5 seconds
		choose from list {$choices} with title "Devices assigned to ${realname}" with prompt "Please select a device below. Once you select a device you will be presented with further information. If no devices are shown the user has no assigned devices" OK button name "Continue" cancel button name "Cancel" 
	end timeout 
END)

	selectedserial=$(echo "$deviceselection" | sed -e 's/.*Serial: \(.*\), Last.*/\1/')
	
	#Opening IF for User Device lookup
	if [[ "${selectedserial}" = "false" ]]; then
	echo "${jpsloggeduser} has selected Close"
	fCloseLostMode
		
	elif [[ "${selectedserial}" != "" ]]; then
		echo "${jpsloggeduser} has selected ${selectedserial}" 
		fDeviceInfo		
	else 
    echo "An applescript timeout occured at user lookup selection" 
	ERROR="An AppleScript timeout has occured please try again." fErrorMessage

	#Closing FI for User Device lookup 
	fi
}

fDeviceInfo ()
{
	selecteddevicedata=$(curl -H "Accept: text/xml" -sfku "${apiuser}:${apipass}" "${jssurl}/JSSResource/mobiledevices/serialnumber/$selectedserial")			
	devicename=$(echo "${selecteddevicedata}" | xpath /mobile_device/general/device_name[1] 2>/dev/null | awk -F'>|<' '{print $3}')
	serial=$(echo "${selecteddevicedata}" | xpath /mobile_device/general/serial_number[1] 2>/dev/null | awk -F'>|<' '{print $3}')
	invupdate=$(echo "${selecteddevicedata}" | xpath /mobile_device/general/last_inventory_update[1] 2>/dev/null | awk -F'>|<' '{print $3}')
	realname=$(echo "${selecteddevicedata}" | xpath /mobile_device/location/realname[1] 2>/dev/null | awk -F'>|<' '{print $3}')
	username=$(echo "${selecteddevicedata}" | xpath /mobile_device/location/username[1] 2>/dev/null | awk -F'>|<' '{print $3}')
	jssid=$(echo "${selecteddevicedata}" | xpath /mobile_device/general/id[1] 2>/dev/null | awk -F'>|<' '{print $3}')
	jsstag=$(echo "${selecteddevicedata}" | xpath /mobile_device/general/asset_tag[1] 2>/dev/null | awk -F'>|<' '{print $3}')
	schoolname=$(echo "${selecteddevicedata}" | xpath /mobile_device/extension_attributes/extension_attribute[13]/value 2>/dev/null | awk -F'>|<' '{print $3}')
	lmstat=$(echo "${selecteddevicedata}" | xpath /mobile_device/security/lost_mode_enabled[1] 2>/dev/null | awk -F'>|<' '{print $3}')
	
	if [[ "${lmstat}" = "true" ]]; then
		LMSTATUS="ENABLED"
		lmbutton="Disable"
	elif [[ "${lmstat}" = "false" ]]; then
		LMSTATUS="DISABLED"
		lmbutton="Enable"
	elif [[ "${lmstat}" = "Unsupervised Device" ]]; then
		ERROR="The selected device is not managed and cannot be put in lost mode. \n\nJPS Reports Status: $lmstat"  fErrorMessage
	elif [[ "${lmstat}" = "Unsupported OS Versione" ]]; then
		ERROR="The selected device does not have a support iOS version. (Requires iOS 10 or higher) please submit this serial for review. \n\nJPS Reports Status: $lmstat"  fErrorMessage
	else
		echo "Invalid API info from Jamf Pro Server" 
		ERROR="An invalid response was recieved from the Jamf Pro Server please contact support. \n\nJPS Reports Status: $lmstat"  fErrorMessage
	fi

	devicewindow=$(/usr/bin/osascript<<END
	with timeout of ${osatimeout} seconds
	tell application "Self Service"
	activate 
	set the answer to button returned of (display dialog "LOST MODE IS CURRENTLY ${LMSTATUS}\n\nDevice Name: $devicename\nSerial Number: $serial\nAsset tag: $jsstag\nLast Inventory Update: $invupdate\n\nUser Information\nReal Name: $realname\nUsername: $username\nSchool: $schoolname\n\nJSS Device ID: $jssid" buttons {"Close", "${lmbutton} Lost Mode"} default button 2 with title "LOST MODE IS CURRENTLY ${LMSTATUS}" giving up after ${osagiveup})
	end tell 
	end timeout
END)

	if [[ "${devicewindow}" = "Enable Lost Mode" ]]; then
		fDeviceStateWindow
	elif [[ "${devicewindow}" = "Disable Lost Mode" ]]; then
		fDisableLostMode
	elif [[ "${devicewindow}" = "Close" ]]; then
		echo "${jpsloggeduser} has selected Close"
			fCloseLostMode
	else
		echo "Error or AppleScript Timeout" 
		ERROR="An Apple Script timeout occured please reopen the program"  fErrorMessage
	fi
	
}

fDeviceStateWindow ()
{
	devicestate=$(/usr/bin/osascript<<END
	tell application "Self Service"
	activate
	(choose from list {"Lost", "Stolen"} with title "Device State Selection" with prompt "Is the device lost or stolen? \nThis information is used for reporting purposes" OK button name "Enable Lost Mode" cancel button name "Close" default items {"Lost"})
	end tell
END)

	if [[ "${devicestate}" = "false" ]]; then		
		echo "${jpsloggeduser} has selected Close"
			fCloseLostMode
	elif [[ "${devicestate}" != "" ]]; then 	
		echo "${jpsloggeduser} has set the device state as ${devicestate}" 
		fUserNotes	
	else		
		ERROR="AppleScript timeout error occured, please try again." fErrorMessage
	fi

}

fUserNotes ()
{
	usernotes=$(/usr/bin/osascript<<END
	with timeout of ${osatimeout} seconds
	tell application "Self Service" 
	activate
	display dialog "Please enter any notes on the device, for example who reported the device stolen and when. Ex. Nitro High Reported missing on 05/01/2020, Please note that this does clear any earlier notes. If you do note enter a device note you will recieve an error." buttons {"Close", "Continue"} default answer "" default button 2 with title "Lost Mode - User Notes" giving up after ${osagiveup}
	copy the result as list to {text_returned, button_pressed}	
	end tell
	end timeout
END)
notes_button_returned=$(echo "$usernotes" | awk -F, '{ print $1 }')

notes_text_returned=$(echo "$usernotes" | awk -F, '{ print $2 }' | xargs echo -n)
	
	if [[ "${notes_button_returned}" = "" ]]; then
	    echo "An applescript timeout occured at Universal Input" 
		ERROR="An AppleScript timeout has occured please try again." fErrorMessage
	elif [[ "${notes_button_returned}" = "Close" ]]; then
		echo "${jpsloggeduser} has selected Close"
			fCloseLostMode
	elif [[ "${notes_text_returned}" != "" ]]; then 	
	echo "${jpsloggeduser} has entered notes" 
	fEnableLostMode
	elif [[ "${notes_text_returned}" = "" ]]; then 	
	echo "${jpsloggeduser} has not entered any notes" 	
	ERROR="You have not entered any notes before enabling notes, notes are required. Please try again." fErrorMessage
	else		
	ERROR="AppleScript timeout error occured, please try again." fErrorMessage
	fi
}


fEnableLostMode ()
{
	action="Enabled"
	
	#XML File to push via the API to set the device notes tho the earlier determined text
    deviceinvupdatexml="<mobile_device><extension_attributes><extension_attribute><name>Lost Mode - Last Inventory Update</name><value>${invupdate}</value></extension_attribute></extension_attributes></mobile_device>"
	#API call to set the device notes
	setinvupdate=$(curl -w '%{http_code}' -su "${apiuser}:${apipass}" -H "Content-Type: text/xml" "${jssurl}/JSSResource/mobiledevices/id/${jssid}/subset/extensionattributes" -d "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>${deviceinvupdatexml}" -X PUT)
	#Checking status of notes API call
	invupdatestatus=$(echo "${setinvupdate}" | sed 's/.*\(...\)/\1/')
	#XML File to push via the API to set the device notes tho the earlier determined text
	devicenotesxml="<mobile_device><extension_attributes><extension_attribute><name>Notes</name><value>LMuser: ${jpsloggeduser}, Notes: ${notes_text_returned}</value></extension_attribute></extension_attributes></mobile_device>"
	#API call to set the device notes
	setnotes=$(curl -w '%{http_code}' -su "${apiuser}:${apipass}" -H "Content-Type: text/xml" "${jssurl}/JSSResource/mobiledevices/id/${jssid}/subset/extensionattributes" -d "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>${devicenotesxml}" -X PUT)
	#Checking status of notes API call
	notesstatus=$(echo "$setnotes" | sed 's/.*\(...\)/\1/')
	# This line sets the device state using the device state that the user picked with the previous osa script promt 
	devicestatexml="<mobile_device><extension_attributes><extension_attribute><name>Device State</name><value>${devicestate}</value></extension_attribute></extension_attributes></mobile_device>"

	setstate=$(curl -w '%{http_code}' -su "${apiuser}:${apipass}" -H "Content-Type: text/xml" "${jssurl}/JSSResource/mobiledevices/id/${jssid}/subset/extensionattributes" -d "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>${devicestatexml}" -X PUT)

	setstatestatus=$(echo "$setstate" | sed 's/.*\(...\)/\1/')
	
	sleep 2
	
	flushcommandsxml="<commandflush><status>Pending</status><mobile_devices><mobile_device><id>${jssid}</id></mobile_device></mobile_devices></commandflush>"

	flushcommand=$(curl -w '%{http_code}' -su "${apiuser}:${apipass}" -H "Content-Type: text/xml" "${jssurl}/JSSResource/commandflush" -d "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>${flushcommandsxml}" -X POST)

	flushstatus=$(echo "$flushcommand" | sed 's/.*\(...\)/\1/')
							
	sleep 2
	
	data="<mobile_device_command><general><command>EnableLostMode</command><lost_mode_message>${lostmodemessage} Serial Number: ${serial} Asset Tag: ${jsstag}</lost_mode_message><lost_mode_with_sound>true</lost_mode_with_sound><lost_mode_phone>${phonenum}</lost_mode_phone><lost_mode_footnote>_</lost_mode_footnote><always_enforce_lost_mode>true</always_enforce_lost_mode></general><mobile_devices><mobile_device><id>${jssid}</id></mobile_device></mobile_devices></mobile_device_command>"

	enablelmcommand=$(curl -w '%{http_code}' -su "${apiuser}:${apipass}" -H "Content-Type: text/xml" "${jssurl}/JSSResource/mobiledevicecommands/command" -d "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?> ${data}" -X POST)
	
	enablecomandstat=$(echo "${enablelmcommand}" | sed 's/.*\(...\)/\1/')
	

	if [[ "${enablecomandstat}" = "201" ]] && [[ "${setstatestatus}" = "201" ]] && [[ "${flushstatus}" = "201" ]] && [[ "${notesstatus}" = "201" ]] && [[ "${invupdatestatus}" = "201" ]]; then
	echo "${jpsloggeduser} has successfully enabled lost mode on serial number: ${serial}"
	fDeviceSuccess 

	else
				
	echo "There was a problem disabling lost mode on ${serial}, Jamf Pro Server reported an error when submitting API command, Details, Disable Command Status: ${enablecomandstat} Set State Status: ${setstatestatus} Set Note Status: ${notesstatus} Set Invetory Update status: ${invupdatestatus}"
	ERROR="There was a problem disabling lost mode on ${serial}, Jamf Pro Server reported an error when submitting API command, Details, Disable Command Status: ${enablecomandstat} Set State Status: ${setstatestatus} Set Note Status: ${notesstatus} Set Invetory Update status: ${invupdatestatus}" fErrorMessage
	
	fi
}

fDisableLostMode ()
{
	action="Disabled"
						
	#XML File to push via the API to set the device notes tho the earlier determined text
    deviceinvupdatexml="<mobile_device><extension_attributes><extension_attribute><name>Lost Mode - Last Inventory Update</name><value></value></extension_attribute></extension_attributes></mobile_device>"
	#API call to set the device notes
	setinvupdate=$(curl -w '%{http_code}' -su "${apiuser}:${apipass}" -H "Content-Type: text/xml" "${jssurl}/JSSResource/mobiledevices/id/${jssid}/subset/extensionattributes" -d "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>${deviceinvupdatexml}" -X PUT)
	#Checking status of notes API call
	invupdatestatus=$(echo "${setinvupdate}" | sed 's/.*\(...\)/\1/')
	#XML File to push via the API to set the device notes tho the earlier determined text
	devicenotesxml="<mobile_device><extension_attributes><extension_attribute><name>Notes</name><value></value></extension_attribute></extension_attributes></mobile_device>"
	#API call to set the device notes
	setnotes=$(curl -w '%{http_code}' -su "${apiuser}:${apipass}" -H "Content-Type: text/xml" "${jssurl}/JSSResource/mobiledevices/id/${jssid}/subset/extensionattributes" -d "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>${devicenotesxml}" -X PUT)
	#Checking status of notes API call
	notesstatus=$(echo "$setnotes" | sed 's/.*\(...\)/\1/')
	
	devicestatexml="<mobile_device><extension_attributes><extension_attribute><name>Device State</name><value></value></extension_attribute></extension_attributes></mobile_device>"

	setstate=$(curl -w '%{http_code}' -su "${apiuser}:${apipass}" -H "Content-Type: text/xml" "${jssurl}/JSSResource/mobiledevices/id/${jssid}/subset/extensionattributes" -d "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>${devicestatexml}" -X PUT)
	
	setstatestatus=$(echo "$setstate" | sed 's/.*\(...\)/\1/')
	
	data="<mobile_device_command><general><command>DisableLostMode</command></general><mobile_devices><mobile_device><id>${jssid}</id></mobile_device></mobile_devices></mobile_device_command>"

	disablelmcommand=$(curl -w '%{http_code}' -su "${apiuser}:${apipass}" -H "Content-Type: text/xml" "${jssurl}/JSSResource/mobiledevicecommands/command" -d "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?> ${data}" -X POST)
	
	disablecomandstat=$(echo "${disablelmcommand}" | sed 's/.*\(...\)/\1/')

	if [[ "${disablecomandstat}" = "201" ]] && [[ "${setstatestatus}" = "201" ]] && [[ "${notesstatus}" = "201" ]] && [[ "${invupdatestatus}" = "201" ]]; then
	echo "${jpsloggeduser} has successfully disabled lost mode on serial number: ${serial}"
	fDeviceSuccess 
	
	else 
	echo "There was a problem disabling lost mode on ${serial}, Jamf Pro Server reported an error when submitting API command, Details, Disable Command Status: ${disablecomandstat} Set State Status: ${setstatestatus} Set Note Status: ${notesstatus} Set Invetory Update status: ${invupdatestatus}"
	ERROR="There was a problem disabling lost mode on ${serial}, Jamf Pro Server reported an error when submitting API command, Details, Disable Command Status: ${disablecomandstat} Set State Status: ${setstatestatus} Set Note Status: ${notesstatus} Set Invetory Update status: ${invupdatestatus}" fErrorMessage
	fi
}

fDeviceSuccess ()
{
	launchpageorclose=$(/usr/bin/osascript<<END
	with timeout of ${osatimeout} seconds
	tell application "System Events"
	activate
	set the answer to button returned of (display dialog "Lost Mode ${action} on $serial" buttons {"Open Device Record","Close"} default button 2 with title "Lost Mode ${action}" giving up after ${osagiveup})
	end tell
	end timeout 
END)

	if [[ "${launchpageorclose}" = "Open Device Record" ]]; then
	open "${jssurl}/mobileDevices.html?id=${jssid}&o=r\n"
	
	fCloseLostMode
	else
	fCloseLostMode
	fi	
	
}

fCloseLostMode ()
{
	echo "Lost Mode closed"
	exit 0	
}

#This is the welcome screen

welcome=$(/usr/bin/osascript<<END
	with timeout of ${osatimeout} seconds
	tell application "Self Service"
		activate
set the answer to button returned of (display dialog "Hi ${jpsloggeduser} !\n\n\nThis program will allow you to enable or disable lost mode on an iOS device. If you are unsure on how to use this program please contact the ${orgname}" with icon file "tmp:fmi.png" with title "Lost Mode - ${orgname}" buttons {"Close", "Continue"} default button 2 giving up after ${osagiveup})
end tell
end timeout 
END)

if [[ "${welcome}" = "Close" ]]; then
	echo "${jpsloggeduser} has selected Close"
	fCloseLostMode
elif [[ "${welcome}" = "Continue" ]]; then
	fSearchOptions
else
	echo "An applescript timeout occured at the Welcome Screen" 
	ERROR="An AppleScript timeout has occured please try again." fErrorMessage
fi