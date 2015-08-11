#!/bin/bash

gerar_homologacao() {
    source "$KEYCLOAK_DIR"/funcoes.sh
    source "$JBOSS_BPMSUITE_DIR"/funcoes.sh

    $GERA_KEYCLOAK && gerar_keycloak
    log_nr=0
    $GERA_JBOSS_BPMSUITE && gerar_jboss_bpmsuite
}

exec_cmd() {
    local cmd="$@"

    echo "$cmd"
    eval "$cmd"
}

docker_name() {
    local dockerfile='./Dockerfile'

    if [ -f "$dockerfile" ]
    then
        echo $(head -1 "$dockerfile" | cut -d: -f 2)
    else 
        >&2 echo "Arquivo \"$dockerfile\" não encontrado!"
        return 1
    fi
}
