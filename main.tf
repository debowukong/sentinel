resource "aws_cloudwatch_log_group" "example" {
  name              = "example"
  retention_in_days = 14
}

# IAM role for AWS Glue job
resource "aws_iam_role" "glue_service_role" {
  name = "AWSGlueServiceRole-example"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach AWS managed policy for Glue
resource "aws_iam_role_policy_attachment" "glue_service" {
  role       = aws_iam_role.glue_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# Additional policy for S3 access
resource "aws_iam_role_policy" "glue_s3_policy" {
  name = "GlueS3Policy"
  role = aws_iam_role.glue_service_role.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::your-bucket-name/*",
          "arn:aws:s3:::your-bucket-name"
        ]
      }
    ]
  })
}

resource "aws_glue_job" "example" {
  name     = "example-glue-job"
  role_arn = aws_iam_role.glue_service_role.arn
  
  command {
    name            = "glueetl"
    script_location = "s3://your-bucket-name/scripts/your-glue-script.py"
    python_version  = "3"
  }

  default_arguments = {
    # Resource allocation configuration
    "--job-language"                     = "python"
    "--job-bookmark-option"              = "job-bookmark-enable"
    "--TempDir"                          = "s3://aws-glue-temporary-{account-id}/temporary/"
    
    # Performance tuning
    "--enable-glue-datacatalog"          = "true"
    "--enable-spark-ui"                  = "true"
    "--spark-event-logs-path"            = "s3://aws-glue-assets-{account-id}/sparkHistoryLogs/"
    "--enable-job-insights"              = "true"
    "--enable-auto-scaling"              = "true"
    
    # Worker configuration
    "--number-of-workers"                = "5"
    "--worker-type"                      = "G.1X"
    "--max-capacity"                     = "10"
    "--max-retries"                      = "3"
    "--timeout"                          = "2880"  # 48 hours in minutes
    
    # Additional parameters
    "--conf"                             = "spark.sql.sources.partitionOverwriteMode=dynamic"
    "--datalake-formats"                 = "hudi,delta,iceberg"
    "--additional-python-modules"        = "boto3==1.24.91,pandas==1.5.3"
    "--extra-py-files"                   = "s3://bucket-name/path/to/additional/python/modules.zip"
    "--extra-jars"                       = "s3://bucket-name/path/to/additional/jars.jar"
  }
}