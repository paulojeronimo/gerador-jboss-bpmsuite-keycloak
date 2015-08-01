#!/bin/bash

instala_jboss() {
    local script="$JBOSS_INSTALA_DIR"/gerar.sh

    echo -e "\nInstalando JBoss BPM Suite + Keycloak através do script \"$script\"\n"
    BIN_DIR="$INSTALADORES_DIR" JBOSS_DESENVOLVIMENTO_DIR="$FERRAMENTAS_DIR" "$script" -a desenvolvimento
    
    echo -e "\nRecriando o link $JBOSS_LINK para $JBOSS_DIR ..."
    [ -L $JBOSS_LINK ] && unlink $JBOSS_LINK
    ln -s $JBOSS_DIR $JBOSS_LINK
}

remove_jboss() {
    echo "Removendo JBoss BPM Suite + Keycloak ..."
    remove_aplicacao
}
