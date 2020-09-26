#!/bin/bash
set -ex
echo "Running $(basename "${0}") from $(dirname $(readlink -f ${0}))"

LAMBDA="fetch-word-lambda"
FILE="function.zip"

aws lambda update-function-code --function-name ${LAMBDA} --zip-file "fileb://${FILE}"