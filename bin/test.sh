#!/bin/bash

LOC=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
. ${LOC}/common.sh

trap cleanup EXIT

TMP=$(mktemp)
cleanup(){
    rm ${TMP}
}

check_result(){
    grep "You Know, for Search" ${TMP} > /dev/null
    if [ $? -ne 0 ]
    then
        echo "FAILED"
        cat ${TMP}
        exit 1
    else
        echo "OK"
        echo "" > ${TMP}
    fi
}

echo -n "Test curl within master container ... "
docker compose exec es_master \
    curl --cacert config/certs/http_ca.crt -n -s \
    https://localhost:9200 > ${TMP}
check_result

echo -n "Test curl within kibana container ... "
docker compose exec kibana \
    curl --cacert es_master_ca.crt -n \
    https://es_master:9200 > ${TMP}
check_result
