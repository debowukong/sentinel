terraform {
  backend "s3" {
    bucket = "122610525295-bucket-state-file-karpenter"
    region = "us-east-1"
    key    = "karpenter.tfstate"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.79.0"
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
  
  # The example module doesn't accept custom input parameters
  # It uses its own hardcoded values for cluster_name, etc.
}