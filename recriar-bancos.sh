#!/bin/bash

BASEDIR=`cd "$(dirname "$0")"; pwd`
SQL_DIR=${SQL_DIR:-$BASEDIR/scripts-sql}
SQL_USER=${SQL_USER:-system}
SQL_PASSWORD=${SQL_PASSWORD:-oracle}
SQL_HOST=${SQL_HOST:-localhost}
sql=${SQLCL_HOME:-~/Downloads/sqlcl}/bin/sql

$sql -S $SQL_USER/$SQL_PASSWORD@//$SQL_HOST:1521 <<EOF
@"$SQL_DIR/drop-databases.sql"
@"$SQL_DIR/create-databases.sql"
quit;
EOF
