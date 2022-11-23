#!/bin/bash
set -x
export AWS_DEFAULT_REGION=ap-south-1
SERVICE_NAME=travel-agency
ECS_CLUSTER=Demo_cluster
IMAGE_NAME=234111192759.dkr.ecr.ap-south-1.amazonaws.com/travel-agency:latest

#deploy () {
0install add jq https://apps.0install.net/utils/jq.xml
export PATH=/var/lib/jenkins/bin:$PATH
sleep 20
whoami
echo "Deploying to Service"
ecs-deploy -c $ECS_CLUSTER -n $SERVICE_NAME -i $IMAGE_NAME -t 300 --max-definitions 10

#}
#deploy
