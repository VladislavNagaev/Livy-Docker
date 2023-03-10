#!/bin/bash

COMMAND="${1:-}";

if [ "${COMMAND}" == "livy" ]; then

    echo -e "${blue_b}Starting Livy ...${reset_font}";

    ${LIVY_HOME}/bin/livy-server start;

    echo -e "${blue_b}Livy started!${reset_font}";

    tail -f /dev/null;

fi;

exit $?;
