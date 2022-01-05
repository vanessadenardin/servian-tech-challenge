variable "prefix" {
  description = "To help avoid resources name conflicts in the cloud."
  default     = "servian-tech-challenge"
}

variable "vpc_id" {
  description = "VPC to deploy application stack"
}

variable "postgresql_version" {
  description = "PostgreSQL version to be used"
  default     = "10.11"
}

variable "postgresql_password" {
  description = "PostgreSQL database password"
  sensitive   = true
}

variable "production" {
  description = "Is the stack a production deployment?"
}

variable "postgresql_instance_class" {
  description = "PostgreSQL database instance class"
  default     = "db.t3.medium"
}

variable "container_image" {
  description = "Application container image tag"
  default     = "servian/techchallengeapp:latest"
}

variable "certificate_arn" {
  description = "Regional certificate ARN to be used by the load balancer"
  default     = ""
}

variable "domain_name" {
  description = "Domain name of a hosted Route53 zone"
  default     = ""
}
