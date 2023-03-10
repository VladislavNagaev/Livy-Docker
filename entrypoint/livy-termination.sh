#!/bin/bash

COMMAND="${1:-}";

if [ "${COMMAND}" == "livy" ]; then

    echo -e "${blue_b}Ending Livy ...${reset_font}";

    ${LIVY_HOME}/bin/livy-server stop;

fi;

exit $?;
