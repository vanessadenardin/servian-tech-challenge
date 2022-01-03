terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-southeast-2"
}
