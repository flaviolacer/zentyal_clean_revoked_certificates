#!/bin/bash
file="/var/lib/zentyal/CA/index.txt"

echo "Search for Zentyal Revoked Certificates"
idx=0
foundLines=()
while IFS= read -r line
do
	IFS=$'\t' read -r -a arrLine <<< "$line"
        
	if [ "${arrLine[0]}" == "R"  ]
	then
		foundLines[$idx]="$line"
		idx=$((i+1))
	fi	

	#echo "$line"
done < "$file"
if [ $idx -gt 0 ]
then
	echo "Found!"
	echo "Removing"

	for line in "${foundLines[@]}"
	do
		IFS=$'\t' read -r -a arrLine <<< "$line"
		#get certification name
		IFS=$'/' read -r -a infoArrayLine <<< "${arrLine[-1]}"
		#echo "${infoArrayLine[-1]}"
		certName=$(echo "${infoArrayLine[-1]}" | cut -c4-)
		echo "Removing $certName"

		rm "/var/lib/zentyal/CA/keys/${certName}.pem"
		rm "/var/lib/zentyal/CA/private/${certName}.pem"
		rm "/var/lib/zentyal/CA/reqs/${certName}.pem"

		echo "Modifying index file"
		sed "/CN=${certName}/d" -i "/var/lib/zentyal/CA/index.txt"
		echo "Done."
	done

else
	echo "No revoked certificate found."
fi
