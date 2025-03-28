provider "aws" {
  region = "us-east-1"  # Replace with your desired region
}

resource "aws_prometheus_workspace" "example" {
  alias       = "example"
  kms_key_arn = aws_kms_key.example.arn
}

resource "aws_kms_key" "example" {
  description             = "example"
  deletion_window_in_days = 7
}
