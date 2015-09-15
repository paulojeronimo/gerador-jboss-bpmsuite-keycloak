#!/bin/bash

gerar="$JBOSS_EAP_INSTALA_DIR"/gerar

instala_jboss_eap() {
    echo -e "\nInstalando JBoss BPM Suite + Keycloak através do script \"$gerar\"\n"
    BIN_DIR="${BIN_DIR:-$INSTALADORES_DIR}" JBOSS_DESENVOLVIMENTO_DIR="$FERRAMENTAS_DIR" "$gerar" -a desenvolvimento
    
    echo -e "\nRecriando o link $JBOSS_EAP_LINK para $JBOSS_EAP_DIR ..."
    [ -L $JBOSS_EAP_LINK ] && unlink $JBOSS_EAP_LINK
    ln -s $JBOSS_EAP_DIR $JBOSS_EAP_LINK
}

remove_jboss_eap() {
    remove_aplicacao

    echo -e "\nRemovendo arquivos gerados pelo uso do script \"$gerar\"\n"
    BIN_DIR="${BIN_DIR:-$INSTALADORES_DIR}" JBOSS_DESENVOLVIMENTO_DIR="$FERRAMENTAS_DIR" "$gerar" -a desenvolvimento -r -s
}
