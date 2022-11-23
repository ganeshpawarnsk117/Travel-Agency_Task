#!/bin/bash
set -x
export AWS_DEFAULT_REGION=ap-south-1
SERVICE_NAME=travel-agency
ECS_CLUSTER=Demo_cluster

#deploy () {

echo "Deploying to Service"
ecs-deploy -c $ECS_CLUSTER -n $SERVICE_NAME -t 300 --max-definitions 10

#}
#deploy
