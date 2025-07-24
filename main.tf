terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.7.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"
  name    = "blueprints-vpc"
  cidr    = "10.0.0.0/16"
  azs     = ["us-west-2a", "us-west-2b", "us-west-2c"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3"
  
  cluster_name    = "blueprints-eks"
  cluster_version = "1.29"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 2
      desired_size = 1
      instance_types = ["t3.medium"]
    }
  }
}

module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "1.13.1"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider

  # Enable Karpenter add-on with specific version
  enable_karpenter = true

  karpenter = {
    repository     = "oci://public.ecr.aws/karpenter/karpenter"
    chart_version  = "v0.36.1"     # <--- This is what your Sentinel policy will enforce!
    namespace      = "karpenter"
    set            = []
  }
}
