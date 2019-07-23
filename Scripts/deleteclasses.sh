#!/bin/bash

#Input JSS URL for Parameter 4 in the format of https://pizza.jamcloud.com   with no trailing "/"
read -p 'Jamf Pro URL (include https://) : ' jssurl
#API Username, must have read privlidges of computer ojects 
read -p 'Username: ' apiuser
#API Password 
read -sp 'Password: ' apipass

fDeleteClasses ()
{
for id in ${classids[*]}

do

echo "Deleting class ID: $id"

deletecommand=$(curl -w '%{http_code}' -sfu "${apiuser}:${apipass}" "${jssurl}/JSSResource/classes/id/${id}" -X DELETE | sed 's/.*\(...\)/\1/')

if [[ "${deletecommand}" = "200" ]];

then
	echo "Class ID: $id deleted successfully"
	
else echo "Failed to delete, Class ID: $id"

fi

done

echo "finished"
}

echo -e "\nFetching class ids"

sleep 2

classids=$(curl -H "Accept: application/xml" -sfu "${apiuser}:${apipass}" "${jssurl}/JSSResource/classes" | xpath /classes/class/id[1] 2>/dev/null | sed 's$</id>$ $g' | sed 's$<id>$$g' | sed 's/.\{1\}$//')

sleep 2

if [[ "${classids}" != '' ]];

then 

fDeleteClasses

else
	
	echo "Failed to fetch classes, possible auth issue or no classes exist"
	
	exit 0
	
fi