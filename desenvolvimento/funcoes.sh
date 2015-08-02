#!/bin/bash

gerar_desenvolvimento() {
    echo "Gerando o JBoss (standalone) em \"$JBOSS_DESENVOLVIMENTO_DIR\" ..."

    marca_inicio && log "Iniciando em `data_e_hora $dt_hr_inicio`" true

    verificar_downloads
    extrair_jboss_eap "$JBOSS_DESENVOLVIMENTO_DIR"
    #salvar_standalone_xml "$JBOSS_DESENVOLVIMENTO_DIR" 1
    aplicar_patch_do_jboss_eap "$JBOSS_DESENVOLVIMENTO_DIR"
    #salvar_standalone_xml "$JBOSS_DESENVOLVIMENTO_DIR" 2
    extrair_jboss_bpmsuite "$JBOSS_DESENVOLVIMENTO_DIR"
    #salvar_standalone_xml "$JBOSS_DESENVOLVIMENTO_DIR" 3
    aplicar_patches_do_jboss_bpmsuite "$JBOSS_DESENVOLVIMENTO_DIR"
    #salvar_standalone_xml "$JBOSS_DESENVOLVIMENTO_DIR" 4
    extrair_keycloak_overlay "$JBOSS_DESENVOLVIMENTO_DIR"
    extrair_keycloak_adapter "$JBOSS_DESENVOLVIMENTO_DIR"
    copiar_e_substituir "$DESENVOLVIMENTO_DIR" "$JBOSS_DESENVOLVIMENTO_DIR"
    aplicar_patches "$DESENVOLVIMENTO_DIR" "$JBOSS_DESENVOLVIMENTO_DIR"
    salvar_standalone_xml "$JBOSS_DESENVOLVIMENTO_DIR" final 
    instalar_driver_da_oracle "$JBOSS_DESENVOLVIMENTO_DIR"
    remover_modo_domain "$JBOSS_DESENVOLVIMENTO_DIR"
    compactar_jboss_eap "$JBOSS_DESENVOLVIMENTO_DIR"
    gerar_jboss_eap_remove_bat "$JBOSS_DESENVOLVIMENTO_DIR"
    copiar_keycloak_realm "$JBOSS_DESENVOLVIMENTO_DIR"

    marca_fim && log "Geração finalizada em `data_e_hora $dt_hr_fim`. Tempo: `tempo_consumido`" true
}
