#!/bin/bash
set -ex
echo "Running $(basename "${0}") from $(dirname $(readlink -f ${0}))"

FILE="function.zip"
HANLDER="index.js"

zip ${FILE} ${HANLDER}