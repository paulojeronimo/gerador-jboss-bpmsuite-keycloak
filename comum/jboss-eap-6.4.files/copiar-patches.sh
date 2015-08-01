#!/bin/bash

BASEDIR=`cd "$(dirname "$0")"; pwd`
PATCHES_DIR=${PATCHES_DIR:-~/Desktop/gerador-jboss-bpmsuite-keycloak/desenvolvimento/jboss-eap-6.4.files}

find "$PATCHES_DIR" -type f -name '*.patch' -delete

cd "$BASEDIR"

echo "Copiando os patches para \"$PATCHES_DIR\" ..."
for f in $(find . -type f -name '*.patch')
do
    echo "Copiando $f ..."
    rsync -R $f "$PATCHES_DIR"
done
