resource "aws_dax_cluster" "bar" {
  cluster_name       = "cluster-example"
  iam_role_arn       = data.aws_iam_role.example.arn
  node_type          = "dax.r4.large"
  replication_factor = 1

  # Enable server-side encryption for the DAX cluster
  server_side_encryption {
    enabled = true
  }

  # Add tags for resource identification and compliance
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
