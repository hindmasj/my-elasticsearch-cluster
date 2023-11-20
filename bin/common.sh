# Common config for scripts

# Define ELASTIC_PASSWORD STACK_VERSION ES_PORT
TOP=$(dirname ${LOC})
. ${TOP}/.env
export STACK_VERSION

ES_HOME=/usr/share/elasticsearch
KB_HOME=/usr/share/kibana
ES_NODE=es01
NETRC=${TOP}/netrc
CA_CRT=${TOP}/http_ca.crt