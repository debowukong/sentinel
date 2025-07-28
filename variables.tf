variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-2"  # Change to your preferred region
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
  default     = "122610525295"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "karpenter-demo"
}