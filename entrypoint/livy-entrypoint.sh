#!/bin/bash

COMMAND="${1:-}"

source /entrypoint/hadoop-configure.sh

source /entrypoint/spark-configure.sh

source /entrypoint/livy-configure.sh

source /entrypoint/livy-initialization.sh $COMMAND

exec "$@"
