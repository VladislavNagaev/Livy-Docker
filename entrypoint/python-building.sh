#!/bin/bash

owd="$(pwd)"
cd ${PYTHON_HOME}
./configure --enable-optimizations
make --jobs=$(nproc --all)
make altinstall
cd "${owd}"
unset owd
