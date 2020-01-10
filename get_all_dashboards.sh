#!/bin/sh

#set -x

# export KEY=
# export GRAFANA_BASE_URL='http://localhost:3000'


get() {
    curl -q -s --insecure \
         -H "Authorization: Bearer ${KEY}" \
         -H "Content-Type: application/json" \
         -H "Accept: application/json" \
         --url "$@"
         #-vvvvv
}

for f in `get "${GRAFANA_BASE_URL}/api/search/?query=" | jq -r '.[] | "\(.uid);\(.url)"'`
do {
    UID=$(echo $f| cut -d ';' -f1)
    URI=$(echo $f| cut -d ';' -f2)
    NAME=$(basename $URI)
    get "${GRAFANA_BASE_URL}/api/dashboards/uid/$UID" | jq '.| del(.dashboard.id)' > ${UID}.json
} done
