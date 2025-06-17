provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  region = "us-east-1"
}

##############################
# 1. S3 Bucket for Results
##############################

resource "aws_s3_bucket" "athena_results" {
  bucket = "athena-query-results-123456"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket                  = aws_s3_bucket.athena_results.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

##############################
# 2. IAM Policy
##############################

data "aws_iam_policy_document" "athena_least_privilege" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject"
    ]
    resources = [
      aws_s3_bucket.athena_results.arn,
      "${aws_s3_bucket.athena_results.arn}/*"
    ]
  }

  statement {
    actions = [
      "athena:StartQueryExecution",
      "athena:GetQueryExecution",
      "athena:GetQueryResults"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "athena_policy" {
  name        = "AthenaLeastPrivilegePolicy"
  policy      = data.aws_iam_policy_document.athena_least_privilege.json
}

##############################
# 3. IAM Role for Execution
##############################

data "aws_iam_policy_document" "assume_athena" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["athena.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "athena_execution_role" {
  name               = "AthenaExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_athena.json
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.athena_execution_role.name
  policy_arn = aws_iam_policy.athena_policy.arn
}

##############################
# 4. Athena Workgroup
##############################

resource "aws_athena_workgroup" "secure_workgroup" {
  name = "secure-athena-workgroup"

  configuration {
    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena_results.bucket}/"
    }

    execution_role = aws_iam_role.athena_execution_role.arn
  }

  state = "ENABLED"
}
