#!/bin/sh

#set -x
# export KEY=
# export GRAFANA_BASE_URL='http://localhost:3000'
DASHBOARDS_DIR=dashboards

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

if [ ! -d dashboards ]; then
    echo No such file or directory: ./dashboards  >&2
    exit 1
fi


for f in `ls -1 ${DASHBOARDS_DIR}/*.json`
do {

    if [ ! -z "`cat $f | grep 'isFolder'| grep true`" ]; then
        UID=`cat $f |jq '.dashboard.uid' -r`
        TITLE=`cat $f |jq '.dashboard.title' -r`
        VERSION=`cat $f |jq '.dashboard.version' -r`
        echo "{\"uid\": \"$UID\", \"title\": \"$TITLE\"}" > folder.json1
        R=`post ${GRAFANA_BASE_URL}/api/folders "@folder.json1"`
        ID=`echo $R| jq '.id'`
        if [ "$ID" = "null" ]; then
            echo "{\"uid\": \"$UID\",\"title\": \"$TITLE\",\"version\": $VERSION, \"overwrite\": true}" > folder.json1
            R=`put ${GRAFANA_BASE_URL}/api/folders/$UID "@folder.json1"`
            ID=`echo $R| jq '.id'`
        fi
        echo $ID > UID_${UID}_ID
        echo $TITLE > UID_${UID}_TITLE
        echo "Created $TITLE with ID: $ID"
        rm folder.json1
    fi
} done

for f in `ls -1 ${DASHBOARDS_DIR}/*.json`
do {
    if [ ! -z "`cat $f | grep 'isFolder'| grep false`" ]; then
        UID=`cat $f |jq '.meta.folderUrl' -r |sed -e 's/.*\/dashboards\/f\///g' -e 's/\/.*//g'`
        TITLE=`cat $f |jq '.dashboard.title' -r`
        if [ -f "UID_${UID}_ID"  ]; then
            F_ID=`cat UID_${UID}_ID`
            cat $f | jq ".folderId = $F_ID" | jq '.overwrite = true' > ${f}.new
            post ${GRAFANA_BASE_URL}/api/dashboards/db "@${f}.new"  | jq
            rm -f ${f}.new
        else
            cat $f | jq '. +={"overwrite": true }' > ${f}.new
            post ${GRAFANA_BASE_URL}/api/dashboards/db "@${f}.new" | jq
        fi
    fi
} done


rm -f UID_*
rm -f *.new
