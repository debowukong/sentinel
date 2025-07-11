provider "aws" {
  region = "us-east-1"
}
resource "aws_ebs_snapshot_block_public_access" "example" {
  state = "block-all-sharing"
}