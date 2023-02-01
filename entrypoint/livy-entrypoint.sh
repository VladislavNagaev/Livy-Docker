#!/bin/bash

COMMAND="${1:-}"

livy-termination() {
    source /entrypoint/livy-termination.sh $COMMAND
}

source /entrypoint/wait_for_it.sh

source /entrypoint/hadoop-configure.sh

source /entrypoint/spark-configure.sh

source /entrypoint/livy-configure.sh

source /entrypoint/livy-initialization.sh $COMMAND &

trap livy-termination SIGTERM HUP INT QUIT TERM

# Wait for any process to exit
wait -n
