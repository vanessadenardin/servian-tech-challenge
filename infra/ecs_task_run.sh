#!/bin/sh
# This script runs a standalone ECS Task to update/migrate the database for the tech challenge
# this only needs to be run once to prepare the db
# the script overwrite the Task Definition container command from "serve" to "updatedb -s"
terraform init

SUBNET=$(terraform output standalone_task_subnet)
SG=$(terraform output standalone_task_sg)
CLUSTER_NAME=$(terraform output ecs_cluster_name | sed 's/"//g')
TASK_NAME=$(terraform output prefix | sed 's/"//g')
PUBLIC_IP="ENABLED"

aws ecs run-task \
    --task-definition $TASK_NAME \
    --cluster $CLUSTER_NAME \
    --count 1 \
    --launch-type FARGATE \
    --network-configuration '{ "awsvpcConfiguration": {"subnets": [ '$SUBNET' ], "securityGroups": [ '$SG' ], "assignPublicIp": "'$PUBLIC_IP'"}}' \
    --overrides '{ "containerOverrides": [ { "name": "app", "command": ["updatedb", "-s"] } ] }'
