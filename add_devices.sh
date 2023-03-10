#!/bin/bash

# Copyright (C) CampusIoT,  - All Rights Reserved
# Written by CampusIoT Dev Team, 2016-2018

# ------------------------------------------------
# Add new devices in an application
# ------------------------------------------------

# Parameters
if [[ $# -ne 5 ]] ; then
    echo "Usage: $0 JWT ORGID APP_NAME DEV_PROFILE_NAME CSVFILE"
    exit 1
fi

TOKEN="$1"
ORGID="$2"
APPNAME="$3"
PROFNAME="$4"
CSVFILE="$5"


AUTH="Grpc-Metadata-Authorization: Bearer $TOKEN"
#sudo npm install -g jwt-cli
#jwt $TOKEN

# Installation
if ! [ -x "$(command -v jq)" ]; then
  echo 'jq is not installed. Installing jq ...'
  sudo apt-get install -y jq
fi

if ! [ -x "$(command -v curl)" ]; then
  echo 'curl is not installed. Installing curl ...'
  sudo apt-get install -y curl
fi

# Content-Type
ACCEPT_JSON="Accept: application/json"
ACCEPT_CSV="Accept: text/csv"
CONTENT_JSON="Content-Type: application/json"
CONTENT_CSV="Content-Type: text/csv"

# LOCAL
#PORT=8888
#URL=http://localhost:$PORT

# PROD
PORT=443
URL=https://lns.campusiot.imag.fr:$PORT

# Operations
#CURL="curl --verbose"
#CURL="curl --verbose --insecure"
CURL="curl -s --insecure"
GET="${CURL} -X GET --header \""$ACCEPT_JSON"\""
POST="${CURL} -X POST --header \""$ACCEPT_JSON"\""
PUT="${CURL} -X PUT --header \""$ACCEPT_JSON"\""
DELETE="${CURL} -X DELETE --header \""$ACCEPT_JSON"\""
OPTIONS="${CURL} -X OPTIONS --header \""$ACCEPT_JSON"\""
HEAD="${CURL} -X HEAD --header \""$ACCEPT_JSON"\""

# https://stedolan.github.io/jq/manual/
${GET} --header "$AUTH" --header "$CONTENT_JSON"  "${URL}/api/applications?limit=9999&organizationID=$ORGID" > .applications.json
#jq '.result' .applications.json
#jq '.result[] | select(.name == "FTD") | .id | tonumber' .applications.json
APPID=$(jq '.result[] | select(.name == "'$APPNAME'") | .id | tonumber' .applications.json)

${GET} --header "$AUTH" --header "$CONTENT_JSON"  "${URL}/api/device-profiles?limit=999&applicationID=$APPID" > .device-profiles.json
#jq '.result' device-profiles.json
#jq '.result[] | select(.name == "FTD")' .device-profiles.json
#jq '.result[] | select(.name == "FTD") | .id' .device-profiles.json
PROFID=$(jq '.result[] | select(.name == "'$PROFNAME'") | .id' .device-profiles.json)
echo $PROFID

#${GET} --header "$AUTH" --header "$CONTENT_JSON"  "${URL}/api/devices?limit=9999&applicationID=$APPID" > .devices.json
#jq '.result' .devices.json

OLDIFS=$IFS
IFS=","
while read NAME DESCR DEVEUI APPKEY
 do
   echo; echo Create device: $NAME $DESCR $DEVEUI $APPKEY
   echo '{"device":{"name":"'$NAME'","description":"'$DESCR'","devEUI":"'$DEVEUI'","deviceProfileID":'$PROFID',"applicationID":"'$APPID'"}}' > .device-$DEVEUI.json
   curl -s --insecure --data "@.device-$DEVEUI.json" --header "$AUTH" --header "$CONTENT_JSON"  "${URL}/api/devices"
   #${POST}  --data '{"device":{"name":"'$NAME'","description":"'$DESCR'","devEUI":"'$DEVEUI'","deviceProfileID":'$PROFID',"applicationID":"'$APPID'"}}' --header "$AUTH" --header "$CONTENT_JSON"  "${URL}/api/devices"
   echo;
   curl -s --insecure --data '{"deviceKeys":{"nwkKey":"'$APPKEY'","devEUI":"'$DEVEUI'"}}' --header "$AUTH" --header "$CONTENT_JSON"  "${URL}/api/devices/$DEVEUI/keys"
 done < $CSVFILE
IFS=$OLDIFS

echo;

#${GET} --header "$AUTH" --header "$CONTENT_JSON"  "${URL}/api/devices?limit=9999&applicationID=$APPID" --output .devices.json
#jq '.result' .devices.json
