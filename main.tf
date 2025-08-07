provider "aws" {
  region = "us-east-1" # Change as needed
}

data "aws_vpc_endpoint_service" "cloudwatch" {
  service      = "monitoring"
  service_type = "Interface"
}

resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "example" {
  vpc_id                  = aws_vpc.example.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_security_group" "endpoint_sg" {
  name        = "cloudwatch-endpoint-sg"
  vpc_id      = aws_vpc.example.id
  description = "Allow HTTPS for VPC endpoint"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.example.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_endpoint" "cloudwatch" {
  vpc_id             = aws_vpc.example.id
  service_name       = data.aws_vpc_endpoint_service.cloudwatch.service_name
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [aws_subnet.example.id]
  security_group_ids = [aws_security_group.endpoint_sg.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint_policy" "cloudwatch" {
  vpc_endpoint_id = aws_vpc_endpoint.cloudwatch.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "AllowCloudWatchActions",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "cloudwatch:GetMetricData",
          "cloudwatch:PutMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics"
        ],
        "Resource": "*"
      }
    ]
  })
}
