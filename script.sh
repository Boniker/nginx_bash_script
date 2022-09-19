#!/bin/bash
#set -ex

# Variables
FILE=$1

# File validation check
if [[ -f "$FILE" && "$FILE" == *.log ]] ; then
	echo "INFO: $FILE exists and the extension .log is correct";
else
	echo "ERROR: The current file does not exist or extension is not correct";
	exit 1
fi

# Example 1: awk + sort =(set)
awk '{a[$1]++} END{for(i in a){print i" - "a[i] | "sort -k3,3 -nr"}}' $FILE > uniq_list_of_ips_v1.txt

# Example 2: uniq + sort + awk =(set)
awk '{print $1}' $FILE | sort | uniq -c | sort -nr | awk '{print $2 " - " $1}' > uniq_list_of_ips_v2.txt

# Hard level task
COUNTER=0
TOTAL=`awk '{print $1}' nginx.access.log | sort | uniq | wc -l`
while IFS=' - ' read ip count; do
    echo -ne "Processed: $((100*COUNTER/TOTAL))% of all IPs.($COUNTER/$TOTAL)  \r"

    if [[ $ip == "127.0.0.1" ]]; then
      country_code="Loopback"
    elif [[ $ip =~ ^(192\.168|10\.|172\.1[6789]\.|172\.2[0-9]\.|172\.3[01]\.) ]]; then
      country_code="Private IP"
    else
      country_code=`curl -s ipinfo.io/$ip/country`
    fi

    printf "$ip - $count - $country_code\n" >> hard_level_results.txt
    ((COUNTER+=1))
done < uniq_list_of_ips_v1.txt