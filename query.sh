#!/bin/sh

api_link="$1"

####### PRESET VARIABLES:

api_link="${api_link/TODAY_START/$(date "+%Y-%m-%dT00:00:00.000Z")}" # UTC time.
api_link="${api_link/TODAY_END/$(date "+%Y-%m-%dT23:59:59.000Z")}" # UTC time.
api_link="${api_link/DAYSTART/T00:00:00.000Z}"
api_link="${api_link/DAYEND/T23:59:59.000Z}"

api_link="${api_link/TODAY_PLUS_10/$(date -v "+10d" "+%Y-%m-%dT23:59:59.000Z")}" # UTC

####### END OF PRESET VARIABLES

tokenfile="/tmp/msgtoken"
tokenout="/tmp/msgraph.json"

if [ ! -e $tokenfile ]; then
	poetry run python auth.py > $tokenfile
	[ "$?" != "0" ] && exit 1 
fi  
ACCESS_TOKEN="$(cat $tokenfile)"

response="$(curl $api_link -H "Authorization: Bearer $ACCESS_TOKEN" -H "x-ms-version: 2019-02-02" 2>/dev/null 3>/dev/null)"

#echo "LINK IS $api_link" >> /tmp/debug.txt
#echo "RESPONSE IS $response" >> /tmp/debug.txt
#echo "---" >> /tmp/debug.txt


if [ $(echo "$response" | head -1 | grep error | wc -l) = 1 ]; then
	rm $tokenfile
	$0 "$@"
else
	# no error!
	echo $response | tr -d "\r" | tr -d "\n" > $tokenout

	for q in "$@"; do
		# skipping first argument (the api url)
		[ "$q" = "$1" ] && continue

		cat $tokenout | /opt/homebrew/bin/jq -r "$q" #| sed -E 's/"([^"]+)":/\1:/g' | sed -E "s/^[[:space:]]+[@]*//g" | sed -E "s/([a-zA-Z_0-9]+)[.]([a-zA-Z_0-9]+):/\1\2:/g" | tr -d "\n"
		exit 0 #only one command for now
	done
fi

