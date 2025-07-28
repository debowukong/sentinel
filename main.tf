terraform {
  backend "s3" {
    bucket = "122610525295-bucket-state-file-karpenter"
    region = "ap-southeast-2"
    key    = "karpenter.tfstate"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.61.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.7.0"
    }
  }
}

provider "aws" {
  region = var.region
  allowed_account_ids = [var.aws_account_id]
}

module "eks_karpenter" {
  source  = "terraform-aws-modules/eks/aws//examples/karpenter"
  version = "20.8.3"
  
  # These are optional - the module has defaults but you can override them
  cluster_name    = var.cluster_name
  cluster_version = "1.30"
  vpc_cidr        = "10.0.0.0/16"
}