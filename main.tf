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
      version = "2.5.1" # Use only one specific version
    }
  }
}

provider "aws" {
  region = var.region
  allowed_account_ids = [var.aws_account_id]
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

# Data sources to get EKS cluster info
data "aws_eks_cluster" "cluster" {
  name = module.eks_karpenter.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks_karpenter.cluster_name
}

module "eks_karpenter" {
  source  = "terraform-aws-modules/eks/aws//examples/karpenter"
  version = "19.15.3" # Version compatible with Helm 2.5.1
  
  # The example module doesn't accept custom input parameters
}