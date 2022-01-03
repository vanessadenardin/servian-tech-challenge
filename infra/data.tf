data "aws_availability_zones" "azs" {}

data "aws_vpc" "selected" {
    id = var.aws_vpc
}

data "aws_subnets" "available" {
  filter {
    name   = "vpc-id"
    values = [var.aws_vpc]
  }
}
