#!/bin/bash

log_nr=0

log() {
    local op=$1
    local inc=${2:-false}

    $inc && echo -e "\n$((++log_nr))) $op ..." || echo -e "* $op ..."
}

cp_with_parents() {
    local from=$1
    local to=$2

    case $OSTYPE in
        darwin*)
            rsync -R "$from" "$to"
            ;;
        cygwin|linux*)
            cp --parents "$from" "$to"
            ;;
        *)
            echo "TODO: implement cp_with_parents to \"$OSTYPE\""
            ;;
    esac
}

mostrar_cabecalho() {
    echo '###################################################'
    echo 'Script de geração: JBoss BPM Suite + Keycloak      '
    echo "Arquivo de configuração: `basename "$CONFIG"`      "
    echo "Ambiente: $AMBIENTE                                "
    echo 'Autor: Paulo Jerônimo (paulojeronimo@gmail.com)    '
    echo '###################################################'
    echo
}

valida_ambiente() {
    local ambiente=$1

    case "$ambiente" in
        desenvolvimento|homologacao)
            echo $ambiente
            ;;
        *)
            >&2 echo "O ambiente informado ($ambiente) é inválido!"
            return 1
            ;;
    esac 
}

valida_servidor() {
    local servidor=$1

    case "$servidor" in
        dc|hc)
            echo $servidor
            ;;
        *)
            >&2 echo "O servidor informado ($servidor) é inválido!"
            return 1
            ;;
    esac
}

sai() {
    local msg=${1:-"Encerrando aplicação ... :( verifique as mensagens anteriores!"}

    echo "$msg"
    exit 1
}

marca_inicio() {
    dt_hr_inicio=$(date +%s)
}

marca_fim() {
    dt_hr_fim=$(date +%s)
}

tempo_consumido() {
    echo $((dt_hr_fim-dt_hr_inicio)) | awk '{print (int($1/60)" minuto(s) e "int($1%60)" segundo(s)")}'
}

data_e_hora() {
    local n=${1:-`date +%s`}
    case $OSTYPE in
        cygwin|linux*) date -d @$n +"%d/%m/%y-%H:%M:%S";;
        darwin*) date -r $n +"%d/%m/%y-%H:%M:%S";;
    esac
}

remover_gerados() {
    local dir=${1:-$PROJECT_HOME}
    echo "Removendo arquivos e diretórios gerados ..."

    find "$dir" \( -type d -name "$JBOSS_EAP_DIR" \) \
        -o \( -type f -name "${JBOSS_EAP_DIR}.zip" \) \
        -o \( -type f -name "${JBOSS_EAP_DIR}.remove.bat" \) \
        -o \( -type d -name "$JBOSS_BPMSUITE_PATCH_DIR_1" \) \
        | xargs -I {} rm -rf "{}"
}

verificar_downloads() {
    local download_necessario=false
    local f

    log "Verificando a existência dos binários que compõe a geração" true

    for f in $DOWNLOADS
    do
        if [ -f "$BIN_DIR"/$f ]
        then
            log "Encontrado o arquivo \"$f\""
        else
            log "Arquivo \"$f\" não encontrado!"
            download_necessario=true
            continue
        fi
    done
    if $download_necessario
    then
        echo "Para continuar, disponiblize o(s) arquivo(s) acima em \"$BIN_DIR\"!"
        exit
    fi
}

extrair_jboss_eap() {
    local dir=$1

    log "Instalando o JBoss EAP (pelo arquivo $JBOSS_EAP)" true
    if [ -d "$dir/$JBOSS_EAP_DIR" ]
    then
        log "Removendo a instalação atual em \"$dir/$JBOSS_EAP_DIR\""
        rm -rf "$dir/$JBOSS_EAP_DIR"
    fi

    log "Extraindo o binário do JBoss EAP"
    unzip -qo "$BIN_DIR"/$JBOSS_EAP -d "$dir"
}

utilizar_jboss_eap_native_utils() {
    local dir=$1
    local native=$JBOSS_EAP_NATIVE_UTILS_WINDOWS

    log "Instalando o JBoss EAP Native Utilities" true
    case $PLATAFORMA_ALVO in
        Windows):;;
        *)
            log "A plataforma \"$PLATAFORMA_ALVO\" ainda não está configurada para o uso desta função!"
            return
            ;;
    esac

    log "Extraindo o arquivo $native"
    if [ ! -d "$dir/$JBOSS_EAP_DIR" ]
    then
        log "O diretório \"$dir/$JBOSS_EAP_DIR\" não foi encontrado"
    fi

    unzip -qo "$BIN_DIR"/$native -d "$dir"
}

aplicar_patch_do_jboss_eap() {
    local dir=$1
    local modo=${2:-standalone}
    local cmd

    log "Aplicando o patch \"$JBOSS_EAP_PATCH\" no JBoss EAP" true

    cmd="patch apply"
    case $modo in
        standalone)
            [ "$OSTYPE" = "cygwin" ] && \
                cmd="$cmd $(cygpath -w "$BIN_DIR/$JBOSS_EAP_PATCH")" || \
                cmd="$cmd \"$BIN_DIR/$JBOSS_EAP_PATCH\""
            ;;
        domain)
            log "Executando o patch no modo domain"
            [ "$OSTYPE" = "cygwin" ] && \
                cmd="$cmd $(cygpath -w "$BIN_DIR/$JBOSS_EAP_PATCH")" || \
                cmd="$cmd \"$BIN_DIR/$JBOSS_EAP_PATCH\""
            ;;
    esac
    
    JBOSS_HOME="$dir/$JBOSS_EAP_DIR" "$dir/$JBOSS_EAP_DIR"/bin/jboss-cli.sh --command="$cmd"
}

extrair_jboss_bpmsuite() {
    local dir=$1

    log "Extraindo o arquivo $JBOSS_BPMSUITE" true
    unzip -qo "$BIN_DIR"/$JBOSS_BPMSUITE -d "$dir"
}

extrair_jboss_brms() {
    local dir=$1

    log "Extraindo o arquivo $JBOSS_BRMS" true
    unzip -qo "$BIN_DIR"/$JBOSS_BRMS -d "$dir"
}

extrair_keycloak_overlay() {
    local dir=$1

    log "Extraindo o arquivo $KEYCLOAK_OVERLAY" true
    unzip -qo "$BIN_DIR"/$KEYCLOAK_OVERLAY -d "$dir/$JBOSS_EAP_DIR" 
}

extrair_keycloak_adapter() {
    local dir=$1

    log "Extraindo o arquivo $KEYCLOAK_ADAPTER" true
    unzip -qo "$BIN_DIR"/$KEYCLOAK_ADAPTER -d "$dir/$JBOSS_EAP_DIR" 
}

instalar_modulo() {
    local dir=$1
    local module=$2
    local module_dir="$dir/$JBOSS_EAP_DIR"/`dirname $module`
    local binario=$3

    log "Instalando o arquivo $binario" true
    mkdir -p "$module_dir"
    cp "$BIN_DIR"/$binario "$module_dir"
}

instalar_driver_da_oracle() {
    local dir=$1
    local module=modules/system/layers/base/com/oracle/main/module.xml

    instalar_modulo "$dir" $module $ORACLE_DRIVER
}

copiar_e_substituir() {
    local origem=$1
    local destino=${2:-$origem}
    local f

    copiar_arquivos_de() {
        local d=$1
    
        log "Arquivos em \"$d\""
        cd "$d"
        for f in $(find . -type f ! -name '*.patch')
        do
            cp_with_parents $f "$destino/$JBOSS_EAP_DIR"
        done
        cd - &> /dev/null
    }

    log "Copiando e substituindo arquivos (exceto *.patch) para o JBoss" true
    copiar_arquivos_de "$COMUM_DIR"/$JBOSS_A_CONFIGURAR_DIR
    copiar_arquivos_de "$origem"/$JBOSS_A_CONFIGURAR_DIR
}

aplicar_patches() {
    local origem=$1
    local destino=${2:-$origem}
    local f
   
    aplicar_patches_de() {
        local d=$1
        local f2p

        log "Patches em \"$d\""
        cd "$d"
        for f in $(find . -type f -name '*.patch')
        do
            f2p="$destino"/$JBOSS_EAP_DIR/${f%.patch}
            if [ -f "$f2p" ]
            then
                cp "$f2p" "$f2p.original"
                patch "$f2p" $f
                cp "$f2p" "$f2p.final"
            else
                echo "Ignorando patch para \"${f%.patch}\""
            fi
        done
        cd - &> /dev/null
    }
 
    log "Aplicando patches (*.patch) nos arquivos do JBoss" true
    aplicar_patches_de "$COMUM_DIR"/$JBOSS_A_CONFIGURAR_DIR
    aplicar_patches_de "$origem"/$JBOSS_A_CONFIGURAR_DIR
}

aplicar_jboss_bpmsuite_patch_1() {
    local dir=$1
    local patch_script=$dir/$JBOSS_BPMSUITE_PATCH_DIR_1/apply-updates.sh
    local patch_dir=`dirname "$patch_script"`

    log "Aplicando o patch \"$JBOSS_BPMSUITE_PATCH_1\" no JBoss BPM Suite" true

    log "Removendo o diretório \"$patch_dir\""
    rm -rf "$patch_dir"

    log "Extraindo o arquivo do patch"
    unzip -qo -d "$dir" "$BIN_DIR"/"$JBOSS_BPMSUITE_PATCH_1"

    if [ "$OSTYPE" = "cygwin" ]
    then
        log "Corrigindo o script do patch (arquivo $patch_script)"
        cat <<'EOF' | patch "$patch_script"
--- apply-updates.sh.original   2015-07-07 17:43:36.221290700 -0300
+++ apply-updates.sh    2015-07-07 17:46:33.060889300 -0300
@@ -31,4 +31,4 @@
     JAVA_BIN=java
 fi
 
-${JAVA_BIN} -Xms64m -Xmx512m -cp "libs/*" -Dlogback.configurationFile="conf/logback.xml" org.jboss.brmsbpmsuite.patching.client.BPMSuiteClientPatcherApp "$@"
+"${JAVA_BIN}" -Xms64m -Xmx512m -cp "libs/*" -Dlogback.configurationFile="conf/logback.xml" org.jboss.brmsbpmsuite.patching.client.BPMSuiteClientPatcherApp $(cygpath -w "$1") $2
EOF
    fi

    log "Executando o script do patch ($patch_script)"
    cd "$patch_dir" 
    "$patch_script" "$dir/$JBOSS_EAP_DIR" eap6.x
    cd - &> /dev/null
}

aplicar_patches_do_jboss_bpmsuite() {
    local dir=$1

    aplicar_jboss_bpmsuite_patch_1 "$dir"
}

remover_modo() {
    local dir=$1
    local modo=$2

    log "Removendo diretórios e arquivos relativos ao modo $modo" true

    log "Diretório \"$dir/$JBOSS_EAP_DIR/$modo\""
    rm -rf "$dir/$JBOSS_EAP_DIR"/$modo

    log "Arquivos $modo* de \"$dir/$JBOSS_EAP_DIR/bin\""
    rm -f "$dir/$JBOSS_EAP_DIR"/bin/${modo}*
}

remover_modo_standalone() {
    local dir=$1

    remover_modo "$dir" standalone
}

remover_modo_domain() {
    local dir=$1

    remover_modo "$dir" domain
}

compactar_jboss_eap() {
    local dir=$1
    local exclude

    $NAO_COMPACTAR && return
    log "Compactando o JBoss EAP em "$JBOSS_EAP_DIR".zip" true

    cd "$dir"
    rm -f "$JBOSS_EAP_DIR.zip"
    if [ -f $JBOSS_EAP_DIR.exclude ]
    then
        log "Os arquivos listados abaixo não farão parte do zip"
        cat $JBOSS_EAP_DIR.exclude
        exclude="-x@$JBOSS_EAP_DIR.exclude"
    fi
    zip -r "$JBOSS_EAP_DIR.zip" $exclude "$JBOSS_EAP_DIR" > /dev/null
    cd - &> /dev/null
}

gerar_jboss_eap_remove_bat() {
    local dir=$1
    local file=${JBOSS_EAP_DIR}.remove.bat

    log "Gerando o arquivo $file" true
    if [ "$PLATAFORMA_ALVO" != "Windows" ]
    then
        log "Ignorando a execução dessa função para a plataforma \"$PLATAFORMA_ALVO\""
        return
    fi

    cd "$dir"
    cat > $file <<EOF
rmdir /S /Q ${JBOSS_EAP_DIR}
EOF
    chmod +x $file

    cd - &> /dev/null
}

salvar_standalone_xml() {
    local dir=$1
    local versao=$2

    cp  "$dir/$JBOSS_EAP_DIR"/standalone/configuration/standalone.xml \
        "$dir/$JBOSS_EAP_DIR"/standalone/configuration/standalone.xml.$versao
}

exportar_keycloak_realm() {
    local dir="$PROJECT_HOME"/keycloak/$KEYCLOAK_REALM_NAME

    rm -rf "$dir"
    mkdir -p "$dir"

    "$JBOSS_HOME"/bin/standalone.sh \
        -Dkeycloak.migration.action=export \
        -Dkeycloak.migration.provider=dir \
        -Dkeycloak.migration.dir="$dir" \
        -Dkeycloak.migration.realmName=$KEYCLOAK_REALM_NAME \
        -Dkeycloak.migration.usersExportStrategy=REALM_FILE
}

copiar_keycloak_realm() {
    local dir=$1
    local realm_dir="$PROJECT_HOME"/keycloak/$KEYCLOAK_REALM_NAME

    cp "$realm_dir"/$KEYCLOAK_REALM_NAME-realm.json "$dir/$JBOSS_EAP_DIR"
}

empacotar_apps_para_o_modo_domain() {
    local dir=$1
    local packages_dir="$dir/$JBOSS_EAP_DIR"/packages
    local deployments_dir="$dir/$JBOSS_EAP_DIR"/standalone/deployments
    local f

    log "Empacotando aplicações para o deploy no modo domain" true
    mkdir -p "$packages_dir"
    pushd "$deployments_dir" &> /dev/null
    for f in business-central dashbuilder kie-server
    do
        cd $f.war
        echo "Empacotando a aplicação $f.war"
        zip -rq "$packages_dir"/$f.war .
        cd - &> /dev/null
    done
    popd &> /dev/null
}

desempacotar_apps_para_o_modo_standalone() {
    local dir=$1
    local packages_dir="$dir/$JBOSS_EAP_DIR"/packages
    local deployments_dir="$dir/$JBOSS_EAP_DIR"/standalone/deployments
    local f

    log "Desempacotando aplicações para o deploy no modo standalone" true
    mkdir -p "$deployments_dir"
    pushd "$deployments_dir" &> /dev/null
    for f in business-central dashbuilder kie-server
    do
        unzip -d $f.war -q "$packages_dir"/$f.war
    done
    popd &> /dev/null
}
