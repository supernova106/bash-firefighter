#!/bin/bash

SOURCE_AWS_ACCOUNT_ID="123"
DESTINATION_AWS_ACCOUNT_ID="456"
IMAGE="$1"
if [ !"${IMAGE}" = "" ]; then
    echo "Please input image"
    exit 1
fi
aws ecr get-login-password \
    --region us-west-2 \
| sudo docker login \
    --username AWS \
    --password-stdin ${SOURCE_AWS_ACCOUNT_ID}.dkr.ecr.us-west-2.amazonaws.com
sudo docker pull "${SOURCE_AWS_ACCOUNT_ID}.dkr.ecr.us-west-2.amazonaws.com/${IMAGE}"
sudo docker tag "${SOURCE_AWS_ACCOUNT_ID}.dkr.ecr.us-west-2.amazonaws.com/${IMAGE}" "${DESTINATION_AWS_ACCOUNT_ID}.dkr.ecr.us-west-2.amazonaws.com/${IMAGE}"
aws ecr get-login-password \
    --region us-west-2 \
| sudo docker login \
    --username AWS \
    --password-stdin ${DESTINATION_AWS_ACCOUNT_ID}.dkr.ecr.us-west-2.amazonaws.com
sudo docker push "${DESTINATION_AWS_ACCOUNT_ID}.dkr.ecr.us-west-2.amazonaws.com/${IMAGE}"
