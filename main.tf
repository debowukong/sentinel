provider "aws" {
  region = "us-east-1"
}

#
# VPC
#
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "example-vpc"
  }
}

#
# Subnets (declared as az1, az2, and az3)
#
resource "aws_subnet" "az1" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "example-subnet-az1"
  }
}

resource "aws_subnet" "az2" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "example-subnet-az2"
  }
}

resource "aws_subnet" "az3" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1c"

  tags = {
    Name = "example-subnet-az3"
  }
}

#
# IAM Role for the EKS Cluster
#
resource "aws_iam_role" "cluster" {
  name = "eks-cluster-example"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action    = ["sts:AssumeRole", "sts:TagSession"],
        Effect    = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

#
# EKS Cluster Resource
#
resource "aws_eks_cluster" "demo_example" {
  name = "demo_cluster"

  access_config {
    authentication_mode = "API"
  }

  # Updated IAM role reference:
  role_arn = aws_iam_role.cluster.arn
  version  = "1.31"

  vpc_config {
    subnet_ids = [
      aws_subnet.az1.id,
      aws_subnet.az2.id,
      aws_subnet.az3.id,
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]
}

resource "aws_eks_addon" "example" {
  cluster_name                = "demo_cluster"
  addon_name                  = "coredns"
  addon_version               = "v1.10.1-eksbuild.1"
  resolve_conflicts_on_create = "OVERWRITE"

  configuration_values = jsonencode({
    replicaCount = 4
    resources = {
      limits = {
        cpu    = "100m"
        memory = "150Mi"
      }
      requests = {
        cpu    = "100m"
        memory = "150Mi"
      }
    }
  })
}