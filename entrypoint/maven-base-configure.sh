#!/bin/bash

# Copy files from ${MAVEN_HOME}/ref into ${MAVEN_CON_DIR}
# So the initial ~/.m2 is set with expected content.
# Don't override, as this is just a reference setup

echo "Maven configuration started ..."

copy_reference_files() {

    local log="${MAVEN_CON_DIR}/copy_reference_file.log"
    local ref="${MAVEN_HOME}/ref"

    if mkdir -p "${MAVEN_CON_DIR}/repository" && touch "${log}" > /dev/null 2>&1 ; then
        
        owd="$(pwd)"
        cd "${ref}"
        local reflink=""

        if cp --help 2>&1 | grep -q reflink ; then
            reflink="--reflink=auto"
        fi

        if [ -n "$(find "${MAVEN_CON_DIR}/repository" -maxdepth 0 -type d -empty 2>/dev/null)" ] ; then
            # destination is empty...
            echo "--- Copying all files to ${MAVEN_CON_DIR} at $(date)" >> "${log}"
            cp -rv ${reflink} . "${MAVEN_CON_DIR}" >> "${log}"
        else
            # destination is non-empty, copy file-by-file
            echo "--- Copying individual files to ${MAVEN_CON_DIR} at $(date)" >> "${log}"
            find . -type f -exec sh -eu -c '
                log="${1}"
                shift
                reflink="${1}"
                shift
                for f in "$@" ; do
                    if [ ! -e "${MAVEN_CON_DIR}/${f}" ] || [ -e "${f}.override" ] ; then
                        mkdir -p "${MAVEN_CON_DIR}/$(dirname "${f}")"
                        cp -rv ${reflink} "${f}" "${MAVEN_CON_DIR}/${f}" >> "${log}"
                    fi
                done
            ' _ "${log}" "${reflink}" {} +
        fi

        echo >> "${log}"

        cd "${owd}"
        unset owd

    else
        echo "Can not write to ${log}. Wrong volume permissions? Carrying on ..."
    fi

}

copy_reference_files

echo "Maven configuration completed!"
