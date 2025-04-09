terraform {
  required_version = "0.13.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # Choose a version that is compatible with your configuration.
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

#
# VPC
#
resource "aws_vpc" "example" {
  cidr_block                        = "10.0.0.0/16"
  assign_generated_ipv6_cidr_block  = false
  enable_dns_support                = true
  instance_tenancy                  = "default"

  # tags can be added here if desired
}

#
# Subnets
#
resource "aws_subnet" "example1" {
  vpc_id                           = aws_vpc.example.id
  cidr_block                       = "10.0.1.0/24"
  assign_ipv6_address_on_creation  = false
  map_public_ip_on_launch          = false

  tags = {
    Name = "example1"
  }
}

resource "aws_subnet" "example2" {
  vpc_id                           = aws_vpc.example.id
  cidr_block                       = "10.0.51.0/24"
  assign_ipv6_address_on_creation  = false
  map_public_ip_on_launch          = false

  tags = {
    Name = "example2"
  }
}

#
# IAM Roles
#
resource "aws_iam_role" "example" {
  name = "eks-cluster-example"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
}

resource "aws_iam_role" "eks-node-group" {
  name = "eks-node-group-example"
  assume_role_policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"ec2.amazonaws.com\"}}]}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
}

#
# IAM Role Policy Attachments
#
resource "aws_iam_role_policy_attachment" "example-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.example.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.example.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-node-group.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-node-group.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-node-group.name
}

#
# EKS Cluster
#
resource "aws_eks_cluster" "example" {
  name = "example"

  # (enabled_cluster_log_types is null per your Sentinel file; encryption_config, tags, and timeouts are omitted.)
  vpc_config {
    endpoint_private_access = false
    endpoint_public_access  = true
    # Although the Sentinel “after” block shows only these two values,
    # the aws_eks_cluster resource requires subnet_ids so we supply our two subnets.
    subnet_ids = [
      aws_subnet.example1.id,
      aws_subnet.example2.id,
    ]
    # security_group_ids is left unset (null)
  }

  role_arn = aws_iam_role.example.arn
}

#
# EKS Node Group
#
resource "aws_eks_node_group" "example" {
  cluster_name    = aws_eks_cluster.example.name
  node_group_name = "example"

  scaling_config {
    desired_size = 1
    max_size     = 4
    min_size     = 1
  }

  # In the Sentinel file, launch_template and remote_access are empty.
  # Here we omit these optional blocks.
  
  node_role  = aws_iam_role.eks-node-group.arn
  
  # The subnet_ids attribute is required if no launch_template is configured.
  subnet_ids = [
    aws_subnet.example1.id,
    aws_subnet.example2.id,
  ]
}
