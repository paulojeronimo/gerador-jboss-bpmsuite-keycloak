#!/bin/bash

gerar_keycloak() {
    echo -e "\nGerando JBoss (keycloak) em \"$KEYCLOAK_DIR\" ..."

    extrair_jboss_eap "$KEYCLOAK_DIR"
    utilizar_jboss_eap_native_utils "$KEYCLOAK_DIR"
    aplicar_patch_do_jboss_eap "$KEYCLOAK_DIR"
    extrair_keycloak_overlay "$KEYCLOAK_DIR"
    extrair_keycloak_adapter "$KEYCLOAK_DIR"
    copiar_e_substituir "$KEYCLOAK_DIR"
    aplicar_patches "$KEYCLOAK_DIR"
    instalar_driver_da_oracle "$KEYCLOAK_DIR"

    log 'Removendo arquivos comuns não utilizados: business-central.war e dashbuilder.war' true
    rm -rf "$KEYCLOAK_DIR/$JBOSS_EAP_DIR"/standalone/deployments/{business-central,dashbuilder}.war

    remover_modo_domain "$KEYCLOAK_DIR"
    compactar_jboss_eap "$KEYCLOAK_DIR"
    gerar_jboss_eap_remove_bat "$KEYCLOAK_DIR"
}
