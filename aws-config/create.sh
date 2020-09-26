#!/bin/bash
set -ex
echo "Running $(basename "${0}") from $(dirname $(readlink -f ${0}))"

LAMBDA="fetch-word-lambda"
FILE="function.zip"
# Format is <file>.<function>
HANLDER="index.handler"
# Uses local non file "accountid" containing value
ACCOUNT_ID=$(cat $(dirname $(readlink -f ${0}))/accountid)
LOCAL_ROLE="lambda-execution"

aws lambda create-function --function-name ${LAMBDA} \
--zip-file fileb://${FILE} --handler ${HANLDER} --runtime nodejs12.x \
--role arn:aws:iam::${ACCOUNT_ID}:role/${LOCAL_ROLE}