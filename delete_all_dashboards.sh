#!/bin/sh

if [ "${DEBUG}" ]; then
    set -x
fi

# export KEY=
# export GRAFANA_BASE_URL='http://localhost:3000'


get() {
    curl -q -s --insecure \
         -H "Authorization: Bearer ${KEY}" \
         -H "Content-Type: application/json" \
         -H "Accept: application/json" \
         --url "$@"
}

delete() {
    curl -q -s --insecure -X DELETE \
         -H "Authorization: Bearer $KEY"\
         -H "Content-Type: application/json"\
         -H "Accept: application/json"\
         --url "$@"
    }

for f in `get "http://localhost:3000/api/search/?query=" | jq -r '.[] | "\(.uid);\(.url)"'`
do {
    UID=$(echo $f| cut -d ';' -f1)
    URI=$(echo $f| cut -d ';' -f2)
    NAME=$(basename $URI)
    delete http://localhost:3000/api/dashboards/uid/$UID | jq
} done
