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
}