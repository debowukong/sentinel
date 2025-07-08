provider "aws" {
  region = "us-east-1"
}

resource "aws_organizations_delegated_administrator" "example" {
  account_id        = "123456789012"
  service_principal = "principal"
}