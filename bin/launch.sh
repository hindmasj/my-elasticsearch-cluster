#!/bin/bash

LOC=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
. ${LOC}/common.sh

TMP=$(mktemp)
WAITFOR=30

trap cleanup EXIT
cleanup(){
    rm ${TMP}
}

check_up(){
    docker compose ps --format json $1 > ${TMP}
    grep $1 ${TMP} > /dev/null
    return $?
}

container_list="es_master kibana"
for container in ${container_list}
do
    check_up ${container}
    if [ $? -ne 0 ]
    then
        NEED_UP="${NEED_UP} ${container}"
    fi
done

docker compose up -d ${container_list}

if [ -n "${NEED_UP}" ]
then
    echo "Waiting for containers${NEED_UP}"
    echo "Wait ${WAITFOR}s to ensure containers are running."
    for i in $(seq ${WAITFOR} -1 1); do sleep 1; printf "${i}    \r";done
    echo
fi

ret=1
echo -n "Fetching master CA cert ... "
while [ ${ret} -ne 0 ]
do
    docker cp es_master:${ES_HOME}/config/certs/http_ca.crt . > /dev/null
    ret=$?
    echo -n "."
    sleep 1
done
echo

docker compose cp netrc es_master:${ES_HOME}/.netrc
docker compose cp netrc kibana:${KB_HOME}/.netrc
docker compose cp http_ca.crt kibana:${KB_HOME}/es_master_ca.crt

echo "Fetch enrollment token and verification code."
rm -f enrollment-token
while [ ! -s enrollment-token ]
do
    docker compose exec \
    es_master bin/elasticsearch-create-enrollment-token --scope kibana \
    > enrollment-token
    sleep 1
done
docker compose exec kibana bin/kibana-verification-code > verification-code

echo "Here is the enrollment token"
cat enrollment-token
cat verification-code
