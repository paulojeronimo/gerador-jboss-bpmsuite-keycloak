#!/bin/sh

# Configura a string de conexão com o Oracle
conf=$JBOSS_HOME/domain/configuration/domain.xml
if grep -q ORACLE_CONNECTION_URL $conf
then
    sed -i "s/ORACLE_CONNECTION_URL/jdbc:oracle:thin:@$ORACLE_PORT_1521_TCP_ADDR:1521:xe/g" $conf
fi

# Executa em modo domain
exec $JBOSS_HOME/bin/domain.sh "$@"
