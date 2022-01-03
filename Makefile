init:
	docker-compose run terraform init

plan:
	docker-compose run terraform plan -out terraform.plan

apply:
	docker-compose run terraform apply terraform.plan

destroy:
	docker-compose run terraform destroy
