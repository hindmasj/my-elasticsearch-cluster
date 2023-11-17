#!/bin/bash

LOC=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
. ${LOC}/common.sh

docker compose pull

cat << EOF > netrc
machine localhost
login elastic
password elastic
EOF
