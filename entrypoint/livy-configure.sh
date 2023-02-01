#!/bin/bash

echo "Livy-node configuration started ..."


function configure_conffile() {

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
        echo "${name}=${value}" | tee -a $path > /dev/null

    done
}


function configure_envfile() {

    local path=$1
    local -n envArray=$2

    local name
    local value

    echo "Configuring ${path}"

    for c in "${envArray[@]}"
    do

        name=${c}
        value=${!c}

        if [[ -n ${value} ]]; then
            echo " - Setting ${name}=${value}"
            echo "export ${name}=${value}" >> ${path}
        fi
    
    done
}


if ! [ -z ${LIVY_LOG_DIR+x} ]; then
    mkdir -p ${LIVY_LOG_DIR};
    echo "LIVY_LOG_DIR=${LIVY_LOG_DIR}"
fi


if ! [ -z ${LIVY_CONF_DIR+x} ]; then
    touch ${LIVY_CONF_DIR}/livy.conf;
    configure_conffile ${LIVY_CONF_DIR}/livy.conf LIVY_CONFIG;
fi

if ! [ -z ${LIVY_CONF_DIR+x} ]; then

    declare -a LivyEnv=(
        "JAVA_HOME" "HADOOP_CONF_DIR" "SPARK_HOME" "SPARK_CONF_DIR" "LIVY_LOG_DIR" 
        "LIVY_SERVER_JAVA_OPTS" "LIVY_IDENT_STRING" "LIVY_MAX_LOG_FILES" "LIVY_NICENESS" 
    );

    touch ${LIVY_CONF_DIR}/livy-env.sh;
    configure_envfile ${LIVY_CONF_DIR}/livy-env.sh LivyEnv;

fi


echo "Livy-node configuration completed!"
