#!/bin/bash

echo "Hadoop-node configuration started ..."

function addProperty() {

    local path=$1
    local name=$2
    local value=$3

    local entry="<property><name>$name</name><value>${value}</value></property>"
    local escapedEntry=$(echo $entry | sed 's/\//\\\//g')

    sed -i "/<\/configuration>/ s/.*/${escapedEntry}\n&/" $path

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

configure ${HADOOP_CONF_DIR}/core-site.xml CORE_CONF
configure ${HADOOP_CONF_DIR}/hdfs-site.xml HDFS_CONF
configure ${HADOOP_CONF_DIR}/yarn-site.xml YARN_CONF
configure ${HADOOP_CONF_DIR}/httpfs-site.xml HTTPFS_CONF
configure ${HADOOP_CONF_DIR}/kms-site.xml KMS_CONF
configure ${HADOOP_CONF_DIR}/mapred-site.xml MAPRED_CONF

echo "Hadoop-node configuration completed!"
