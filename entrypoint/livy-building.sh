#!/bin/bash

echo "Livy building started ..."

owd="$(pwd)"

cd ${LIVY_HOME}

# mvn package
mvn clean package -B -V -e -Pspark-3.0 -DskipTests -DskipITs -Dmaven.javadoc.skip=true

cd "${owd}"

echo "Livy building completed!"
