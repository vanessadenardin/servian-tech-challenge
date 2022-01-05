# output "alb_dns_name" {
#   description = "public accessible url to access application"
#   value       = aws_lb.app.dns_name
# }

# output "app_dns_name" {
#   description = "domain cname record to access app"
#   value       = length(aws_route53_record.app) > 0 ? aws_route53_record.app[0].fqdn : null
# }

# output "standalone_task_subnet" {
#   description = "single subnet to run standalone ECS Task to config db"
#   value       = data.aws_subnets.available.ids[0]
# }

# output "standalone_task_sg" {
#   description = "security group to run standalone ECS Task to config db"
#   value       = aws_security_group.app.id
# }

# output "ecs_cluster_name" {
#   description = "ECS cluster name"
#   value       = aws_ecs_cluster.app.name
# }

# output "prefix" {
#   description = "Application prefix"
#   value       = var.prefix
# }
