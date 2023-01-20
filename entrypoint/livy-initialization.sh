#!/bin/bash

COMMAND="${1:-}"

if [ "${COMMAND}" == "livy" ]; then

    echo "Starting Livy ..."

    mkdir -p ${LIVY_LOG_DIR}

    ${LIVY_HOME}/bin/livy-server 

fi
