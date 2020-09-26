#!/bin/bash
set -ex
echo "Running $(basename "${0}") from $(dirname $(readlink -f ${0}))"

LAMBDA="fetch-word-lambda"

aws lambda invoke --function-name ${LAMBDA} invoke.log --log-type Tail \
--query 'LogResult' --output text |  base64 -d 