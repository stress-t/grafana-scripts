#!/bin/sh

# set -x
# export KEY=
# export GRAFANA_BASE_URL='http://localhost:3000'

post() {
    curl -q -s -X POST --insecure \
         -H "Authorization: Bearer $KEY"\
         -H "Content-Type: application/json"\
         -H "Accept: application/json" \
         --url "$1" \
         --data "$2"
    }
put() {
    curl -q -s -X PUT --insecure \
         -H "Authorization: Bearer $KEY"\
         -H "Content-Type: application/json"\
         -H "Accept: application/json" \
         --url "$1" \
         --data "$2"

    }
for f in `ls -1 *.json`
do {
    if ([ ! -z "`cat $f | grep 'isFolder'| grep true`" ]) then {
        cat $f |jq '.| del(.meta)|.dashboard' > folder.json
        R="`post http://localhost:3000/api/folders '@folder.json'`"
        UID=`grep uid $f | awk {'print $2'}|sed -e 's/",//g' -e 's/"//g'`
        TITLE=`grep title $f | awk {'print $2'}|sed -e 's/",//g' -e 's/"//g'`
        ID=`echo $R| jq '.id'`
        if ([ "$ID" = "null"  ]) then {
            cat folder.json | jq '. +={ "overwrite": true}' > folder1.json
            R=`post http://localhost:3000/api/folders/$UID "@folder1.json"`
            ID=`echo $R| jq '.id'`
        } fi
        echo $ID > UID_${UID}_ID
        echo $TITLE > UID_${UID}_TITLE
        rm -f folder.json
        rm -f folder1.json
    } fi
} done

for f in `ls -1 *.json`
do {
    if ([ ! -z "`cat $f | grep 'isFolder'| grep false`" ]) then {
        UID=`cat $f |grep folderUrl |sed -e 's/.*\/dashboards\/f\///g' -e 's/\/.*//g'`
        if ([ -f "UID_${UID}_ID" ]) then {
            F_ID=`cat UID_${UID}_ID`
            cat $f | jq ". +={"folderId": $F_ID}" | jq '. +={"overwrite": true }' > ${f}.new
            post http://localhost:3000/api/dashboards/db @${f}.new  | jq
        } else {
            post http://localhost:3000/api/dashboards/db @${f} | jq
        } fi

    } fi
} done


rm -f UID_*
rm -f *.new
