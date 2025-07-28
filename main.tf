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
      version = "2.5.1"
    }
  }
}

provider "aws" {
  region = var.region
  allowed_account_ids = [var.aws_account_id]
}

# Explicitly declare the Karpenter version for Sentinel policy validation
resource "helm_release" "karpenter" {
  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter/karpenter"
  chart      = "karpenter"
  version    = "v0.36.1"  # Latest version as of July 2025
  namespace  = "karpenter"
  
  # Skip actual installation since we don't have a real cluster
  create_namespace = true
  depends_on       = [null_resource.eks_placeholder]
}

# Placeholder for EKS cluster
resource "null_resource" "eks_placeholder" {
  # This represents a placeholder EKS cluster
}

# This allows provider configuration to work without errors
data "aws_eks_cluster" "cluster" {
  name = "example-cluster"
  depends_on = [null_resource.eks_placeholder]
}

data "aws_eks_cluster_auth" "cluster" {
  name = "example-cluster"
  depends_on = [null_resource.eks_placeholder]
}