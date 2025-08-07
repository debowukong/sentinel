provider "aws" {
  region = "us-east-1" # Change as needed
}

resource "aws_iam_policy" "cloudwatch_vpc_endpoint_policy" {
  name        = "cloudwatch-vpc-endpoint-policy"
  description = "Policy that restricts cloudwatch actions to only be allowed through the VPC endpoint"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Deny"
        Action   = [
          "cloudwatch:DeleteAlarms",
          "cloudwatch:DeleteDashboards",
          "cloudwatch:DeleteMetricStream",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:GetDashboard",
          "cloudwatch:GetMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics",
          "cloudwatch:PutDashboard",
          "cloudwatch:PutMetricAlarm",
          "cloudwatch:PutMetricData"
        ]
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "aws:SourceVpce" = [
              "vpce-0abcd1234efgh5678",  # Approved VPC endpoint ID
              "vpce-0abcd1234ijkl5678"   # Approved VPC endpoint ID
            ]
          }
        }
        Sid = "DenyCloudWatchActionsOutsideVPCEndpoint"
      }
    ]
  })
}