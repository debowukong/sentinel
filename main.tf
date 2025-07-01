provider "aws" {
  region = "us-east-1"
}

resource "aws_secretsmanager_secret" "example" {
  name = "example"

  tags = {
    Environment = "dev"
    Owner       = "team-security"
    Purpose     = "store-credentials"
  }
}
