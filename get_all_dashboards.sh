#!/bin/bash

if [ "${DEBUG}" ]; then
    set -x
fi

# export GRAFANA_KEY=
# export GRAFANA_BASE_URL='http://localhost:3000'
DASHBOARDS_DIR=${DASHBOARDS_DIR:=dashboards}

get() {
    curl -q -s --insecure \
         -H "Authorization: Bearer ${GRAFANA_KEY}" \
         -H "Content-Type: application/json" \
         -H "Accept: application/json" \
         --url "$@"
         #-vvvvv
}

if [ ! -d ${DASHBOARDS_DIR} ]; then
    mkdir ${DASHBOARDS_DIR}
fi

for f in `get "${GRAFANA_BASE_URL}/api/search/?query=" | jq -r '.[] | "\(.uid);\(.url)"'`
do {
    UUID=$(echo $f| cut -d ';' -f1)
    URI=$(echo $f| cut -d ';' -f2)
    NAME=$(basename $URI)
    get "${GRAFANA_BASE_URL}/api/dashboards/uid/$UUID" | jq '.| del(.dashboard.id)' > ${DASHBOARDS_DIR}/${UUID}.json
} done
