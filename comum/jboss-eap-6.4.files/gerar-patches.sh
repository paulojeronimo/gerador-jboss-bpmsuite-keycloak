#!/bin/bash

BASEDIR=`cd "$(dirname "$0")"; pwd`

cd "$BASEDIR"

echo "Gerando os patches em \"$JBOSS_HOME\" ..."
for f in $(find . -type f -name '*.original')
do
    pushd $(dirname $f) &> /dev/null
    echo "Gerando ${f%.original}.patch ..."
    f=$(basename $f)
    diff -uwNr $f ${f%.original} > ${f%.original}.patch
    popd &> /dev/null
done
