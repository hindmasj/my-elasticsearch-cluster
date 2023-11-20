#!/bin/bash

LOC=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
. ${LOC}/common.sh

curl -n --netrc-file ${NETRC} --cacert ${CA_CRT} https://localhost:9200/${@}
