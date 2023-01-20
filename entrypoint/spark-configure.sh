#!/bin/bash

echo "Spark-node configuration started ..."

function addProperty() {

    local path=$1
    local name=$2
    local value=$3

    local entry="${name} ${value}"

    echo ${entry} | tee -a $path > /dev/null

}

function configure() {

    local path=$1
    local envPrefix=$2

    local var
    local value
    
    echo "Configuring $path"

    for c in `printenv | perl -sne 'print "$1 " if m/^${envPrefix}_(.+?)=.*/' -- -envPrefix=$envPrefix`; do 
        name=`echo ${c} | perl -pe 's/___/-/g; s/__/@/g; s/_/./g; s/@/_/g;'`
        var="${envPrefix}_${c}"
        value=${!var}
        echo " - Setting $name=$value"
        addProperty $path $name "$value"
    done
}

configure ${SPARK_CONF_DIR}/spark-defaults.conf SPARK_DEFAULTS

echo "Spark-node configuration completed!"