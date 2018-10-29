#!/bin/bash
######################################################################################################################
# 
######################################################################################################################
# Nicholas McDonald 
# Created on 06/15/2018
# This script is desinged to use the Jamf Pro Classic API to pull the user detials, determine their full name and the 
# local device model and set this combnined info as the computer name in the format of "Nicholas's MacBook Pro"
######################################################################################################################
# 
######################################################################################################################

#Input JSS URL for Parameter 4 in the format of https://pizza.jamcloud.com   with no trailing "/"
jssurl="${4}"
#API Username, must have read permissions of computer ojects 
apiuser="${5}"
#API Password 
apipass="${6}"

#Gets the computers serialnumber
serial=$(ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}')

#Gets the assigned user for the device from jamf pro
firstname=$(curl -H "Accept: application/xml" -sfku "${apiuser}:${apipass}" "${jssurl}/JSSResource/computers/serialnumber/${serial}/subset/location" | xpath /computer/location/realname[1] 2>/dev/null | awk -F'>|<' '{print $3}' | cut -d' ' -f1)

#Determines model name such as "MacBook Pro" 
modeltype=$(system_profiler SPHardwareDataType | grep "Model Name" | awk '{ print $3" "$4}')

#Creates the device name
devicename=$(echo "${firstname}'s ${modeltype}")

#Echos out to log
echo "Setting device name to ${devicename}"

#Uses jamf setComputerName command to set the computers name 
jamf setComputerName -name "${devicename}"

#exits
exit 0
