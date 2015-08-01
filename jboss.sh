#!/bin/bash

gerar="$JBOSS_INSTALA_DIR"/gerar

instala_jboss() {
    echo -e "\nInstalando JBoss BPM Suite + Keycloak através do script \"$gerar\"\n"
    BIN_DIR="$INSTALADORES_DIR" JBOSS_DESENVOLVIMENTO_DIR="$FERRAMENTAS_DIR" "$gerar" -a desenvolvimento
    
    echo -e "\nRecriando o link $JBOSS_LINK para $JBOSS_DIR ..."
    [ -L $JBOSS_LINK ] && unlink $JBOSS_LINK
    ln -s $JBOSS_DIR $JBOSS_LINK
}

remove_jboss() {
    remove_aplicacao

    echo -e "\nRemovendo arquivos gerados pelo uso do script \"$gerar\"\n"
    BIN_DIR="$INSTALADORES_DIR" JBOSS_DESENVOLVIMENTO_DIR="$FERRAMENTAS_DIR" "$gerar" -a desenvolvimento -r -s
}
