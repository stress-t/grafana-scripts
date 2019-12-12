#!/bin/sh

#set -x

KEY='XXXXXXXXXX'

for f in `curl -q -s --insecure -H "Authorization: Bearer $KEY" -H "Content-Type: application/json" -H "Accept: application/json" "http://localhost:3000/api/search/?query=" | jq -r '.[] | "\(.uid);\(.url)"'`                               
do {
    UID=$(echo $f| cut -d ';' -f1)
    URI=$(echo $f| cut -d ';' -f2)
    NAME=$(basename $URI)
    curl -q -s --insecure -X DELETE -H "Authorization: Bearer $KEY" -H "Content-Type: application/json" -H "Accept: application/json" http://localhost:3000/api/dashboards/uid/$UID                                                           
} done
