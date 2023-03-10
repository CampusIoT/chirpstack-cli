#!/bin/bash

# Copyright (C) CampusIoT,  - All Rights Reserved
# Written by CampusIoT Dev Team, 2016-2018

# ------------------------------------------------
# List all the applications
# ------------------------------------------------

# Parameters
if [[ $# -ne 1 ]] ; then
    echo "Usage: $0 JWT"
    exit 1
fi

TOKEN="$1"


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

echo "============================"
echo "Organizations"
echo "----------------------------"
${GET} --header "$AUTH" --header "$CONTENT_JSON"  "${URL}/api/organizations?limit=9999" > .organizations.json
jq '.result[] | ( .id + ": " + .name + " - " + .displayName)' .organizations.json


echo "============================"
echo "Applications"
echo "----------------------------"
${GET} --header "$AUTH" --header "$CONTENT_JSON"  "${URL}/api/applications?limit=9999" > .applications.json
jq '.result[] | ( .id + ": " + .name + " - " + .organizationID + " - " + .description)' .applications.json
