#!/bin/bash

COMMAND="${1:-}"

if [ "${COMMAND}" == "livy" ]; then

    echo "Ending Livy ..."

    ${LIVY_HOME}/bin/livy-server stop

fi

exit $?
