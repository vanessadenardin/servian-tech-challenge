data "aws_availability_zones" "azs" {}

data "aws_vpc" "selected" {
    id = var.vpc_id
}

data "aws_subnets" "available" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}
