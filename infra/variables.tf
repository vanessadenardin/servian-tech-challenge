variable "prefix" {
    default = "servian-tech-challenge"
}

variable "aws_vpc" {}

variable "postgresql_version" {
    default = "10.11"
}

variable "postgresql_password" {}

variable "production" {}

variable "postgresql_instance_class" {
    default = "db.t3.medium"
}

variable "container_image"{
    default = "servian/techchallengeapp:latest"
}
