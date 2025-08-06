resource "aws_dax_cluster" "bar" {
  cluster_name       = "cluster-example"
  iam_role_arn       = "arn:aws:iam::123456789012:role/your-existing-iam-role-name" # Replace with the actual ARN
  node_type          = "dax.r4.large"
  replication_factor = 1

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}