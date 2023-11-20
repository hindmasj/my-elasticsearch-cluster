#!/bin/bash

LOC=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
. ${LOC}/common.sh

cat << EOF > ${NETRC}
machine localhost
login elastic
password ${ELASTIC_PASSWORD}
EOF

docker compose cp ${ES_NODE}:${ES_HOME}/config/certs/ca/ca.crt ${CA_CRT}
