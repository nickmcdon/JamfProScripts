#!/bin/sh

# 08/10/18 Created by Nicholas McDonald
#
# This script is designed to act as an EA in Jamf Pro 
# 
# This script determines if an updated policy banner is installed for scoping purposes 
#
# Add this EA to your jamf pro server, Set the variable of SHASUM to the SHA 256 value of the text file inside of your policy banner RTFD,
# You can easily determine the sha 256 value of your PolicyBanner by running the following command on a Mac with the PolicyBanner Installed
# shasum -a 256 /Library/Security/PolicyBanner.rtfd/TXT.rtf   Only enter the long string before the location path returned by the command. 
#

SHASUM="93c4461d7fdb6cc9ed0caebfcaca9f7b98d32cffd76b88e8e955b5f8d1e34672"

PolicyBannerShasum=$(shasum -a 256 /Library/Security/PolicyBanner.rtfd/TXT.rtf | cut -d " " -f1)

if [ $PolicyBannerShasum = $SHASUM ]; then
	
echo "<result>true</result>"

else
	
echo "<result>false</result>"

fi

exit