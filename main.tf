provider "aws" {
  region = "us-east-1"
}

resource "aws_sns_topic" "secure_topic" {
  name = "secure-sns-topic"
}

resource "aws_sns_topic_policy" "secure_policy" {
  arn    = aws_sns_topic.secure_topic.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowOnlyVPCEndpointAccess"
        Effect    = "Deny"
        Principal = "*"
        Action    = "sns:*"
        Resource  = aws_sns_topic.secure_topic.arn
        Condition = {
          StringNotEquals = {
            "aws:SourceVpce" = aws_vpc_endpoint.sns.id
          }
        }
      },
      {
        Sid       = "AllowVPCEndpointAccess"
        Effect    = "Allow"
        Principal = "*"
        Action    = "sns:*"
        Resource  = aws_sns_topic.secure_topic.arn
      }
    ]
  })
}
