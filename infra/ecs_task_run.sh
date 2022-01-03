#/bin/sh
SUBNET=$(terraform output standalone_task_subnet)
SG=$(terraform output standalone_task_sg)
PUBLIC_IP="ENABLED"

aws ecs run-task \
    --task-definition service \
    --cluster servian-tech-challenge-frontend \
    --count 1 \
    --launch-type FARGATE \
    --network-configuration '{ "awsvpcConfiguration": {"subnets": [ '$SUBNET' ], "securityGroups": [ '$SG' ], "assignPublicIp": "'$PUBLIC_IP'"}}' \
    --overrides '{ "containerOverrides": [ { "name": "app", "command": ["updatedb", "-s"] } ] }'
