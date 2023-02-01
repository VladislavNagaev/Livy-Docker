#!/bin/bash

COMMAND="${1:-}"

if [ "${COMMAND}" == "livy" ]; then

    echo "Starting Livy ..."

    ${LIVY_HOME}/bin/livy-server start

    echo "Livy started!"

    tail -f /dev/null

fi

exit $?
