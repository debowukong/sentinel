provider "aws" {
  region = "us-east-1"
}

resource "aws_elasticache_cluster" "example" {
  cluster_id           = "cluster-example"
  engine               = "memcached"
  node_type            = "cache.m4.large"
  num_cache_nodes      = 2
  parameter_group_name = "default.memcached1.4"
  apply_immediately    = true
  port                 = 11211

  maintenance_window   = "sun:05:00-sun:06:00" # Approved window
}
