provider "aws" {
  region = "us-east-1"
}

##############################
# 1. S3 Bucket for Athena Results
##############################

resource "aws_s3_bucket" "athena_results" {
  bucket = "sentinel-athena-query-results-demo"
  force_destroy = true
}

##############################
# 2. IAM Assume Role Policy
##############################

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["athena.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "athena_execution_role" {
  name               = "sentinel-athena-execution-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

##############################
# 3. Least Privilege Inline IAM Policy
##############################

resource "aws_iam_role_policy" "athena_policy" {
  name = "sentinel-athena-least-privilege-policy"
  role = aws_iam_role.athena_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::sentinel-athena-query-results-demo",
          "arn:aws:s3:::sentinel-athena-query-results-demo/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "athena:StartQueryExecution",
          "athena:GetQueryExecution",
          "athena:GetQueryResults"
        ],
        Resource = ["*"]
      }
    ]
  })
}

##############################
# 4. Athena Workgroup with Execution Role
##############################

resource "aws_athena_workgroup" "secure" {
  name = "sentinel-secure-workgroup"

  configuration {
    result_configuration {
      output_location = "s3://sentinel-athena-query-results-demo/"
    }

    execution_role = aws_iam_role.athena_execution_role.arn
  }

  state = "ENABLED"
}
