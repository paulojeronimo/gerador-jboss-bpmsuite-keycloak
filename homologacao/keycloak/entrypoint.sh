#!/bin/sh

# Cria o usuário de administração
if [[ ! -z "$JBOSS_EAP_MANAGEMENT_USER" ]] && [[ ! -z "$JBOSS_EAP_MANAGEMENT_PASSWORD" ]]
then
    $JBOSS_HOME/bin/add-user.sh --silent -e -u $JBOSS_EAP_MANAGEMENT_USER -p $JBOSS_EAP_MANAGEMENT_PASSWORD
fi

# Remove variáveis temporárias
unset JBOSS_EAP_MANAGEMENT_USER JBOSS_EAP_MANAGEMENT_PASSWORD

# Configura a string de conexão com o Oracle
conf=$JBOSS_HOME/standalone/configuration/standalone.xml
if grep -q ORACLE_CONNECTION_URL $conf
then
    sed -i "s/ORACLE_CONNECTION_URL/jdbc:oracle:thin:@$ORACLE_PORT_1521_TCP_ADDR:1521:xe/g" $conf
fi

# Executa em modo standalone
exec $JBOSS_HOME/bin/standalone.sh "$@"
