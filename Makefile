init:
	docker-compose run terraform init

plan:
	docker-compose run terraform plan -out terraform.plan

apply:
	docker-compose run terraform apply terraform.plan

destroy:
	docker-compose run terraform destroy

output:
	docker-compose run terraform output

update_db:
	cd infra && ./ecs_task_run.sh
