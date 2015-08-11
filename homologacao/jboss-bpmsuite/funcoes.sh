#!/bin/bash

gerar_jboss_bpmsuite() {
    echo -e "\nGerando JBoss (jboss-bpmsuite) em \"$JBOSS_BPMSUITE_DIR\" ..."

    extrair_jboss_eap "$JBOSS_BPMSUITE_DIR"
    utilizar_jboss_eap_native_utils "$JBOSS_BPMSUITE_DIR"
    aplicar_patch_do_jboss_eap "$JBOSS_BPMSUITE_DIR" domain
    extrair_jboss_bpmsuite "$JBOSS_BPMSUITE_DIR"
    aplicar_patches_do_jboss_bpmsuite "$JBOSS_BPMSUITE_DIR"
    extrair_keycloak_adapter "$JBOSS_BPMSUITE_DIR"
    copiar_e_substituir "$JBOSS_BPMSUITE_DIR"
    aplicar_patches "$JBOSS_BPMSUITE_DIR"
    instalar_driver_da_oracle "$JBOSS_BPMSUITE_DIR"

    log "Empacotando aplicações para o deploy" true
    pushd "$JBOSS_BPMSUITE_DIR/$JBOSS_EAP_DIR/standalone/deployments" &> /dev/null
    for f in business-central dashbuilder kie-server
    do
        cd $f.war
        log "Empacotando aplicação $f.war"
        zip -rq "$JBOSS_BPMSUITE_DIR/$JBOSS_EAP_DIR/bpms-packages/$f.war" .
        cd - &> /dev/null
    done
    popd &> /dev/null

    remover_modo_standalone "$JBOSS_BPMSUITE_DIR"
    compactar_jboss_eap "$JBOSS_BPMSUITE_DIR"
    gerar_jboss_eap_remove_bat "$JBOSS_BPMSUITE_DIR"
}
