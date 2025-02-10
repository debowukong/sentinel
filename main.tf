terraform {
  required_version = ">0.13.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.12.0"
    }
  }
}

module "tf-state" {
  source = "./modules/tf-state
}

module "vpc-infra" {
    source = "./modules/vpc
}