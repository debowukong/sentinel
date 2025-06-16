provider "aws" {
  region = "us-east-1"
}

# Replace this with your AWS Account ID
variable "account_id" {
  default = "122610525295"
}

resource "aws_athena_data_catalog" "example" {
  name        = "athena-data-catalog"
  description = "Example Athena data catalog"
  type        = "LAMBDA"

  parameters = {
    "function" = "arn:aws:lambda:eu-central-1:123456789012:function:not-important-lambda-function"
  }

  tags = {
    Name = "example-athena-data-catalog"
  }
}

resource "aws_athena_workgroup" "example" {
  name = "example"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      encryption_configuration {
        encryption_option = "SSE_KMS"
      }
    }
  }
}

resource "aws_athena_capacity_reservation" "example" {
  name        = "example-reservation"
  target_dpus = 24
}
