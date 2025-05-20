provider "aws" {
  region = "us-east-1"
}

data "aws_region" "current" {}

# Replace this with your AWS Account ID
variable "account_id" {
  default = "122610525295"
}

#########################
# VPC and Networking
#########################

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "private" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "private-subnet-${count.index}"
  }
}

data "aws_availability_zones" "available" {}

resource "aws_security_group" "sns_vpce_sg" {
  name   = "sns-vpce-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#########################
# VPC Endpoint for SNS
#########################

resource "aws_vpc_endpoint" "sns" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.sns"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.sns_vpce_sg.id]
  private_dns_enabled = true

  tags = {
    Name = "sns-vpc-endpoint"
  }
}

#########################
# SNS Topic + Policy
#########################

resource "aws_sns_topic" "secure_topic" {
  name = "secure-topic-vpce"
}

data "aws_iam_policy_document" "sns_topic_policy" {
  policy_id = "__default_policy_ID"

  statement {
    sid    = "DenyNonVPCEAccess"
    effect = "Deny"
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission"
    ]
    resources = [aws_sns_topic.secure_topic.arn]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "aws:SourceVpce"
      values   = [aws_vpc_endpoint.sns.id]
    }
  }

  statement {
    sid    = "AllowVPCEAccess"
    effect = "Allow"
    actions = [
      "SNS:*"
    ]
    resources = [aws_sns_topic.secure_topic.arn]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_sns_topic_policy" "secure_policy" {
  arn    = aws_sns_topic.secure_topic.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}
