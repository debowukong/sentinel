
### Terraform Code: Provision S3 Bucket with SSL Enforcement
resource "aws_s3_bucket" "secure_bucket" {
  bucket = var.bucket_name
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = true
  }

  logging {
    target_bucket = var.logging_bucket_name
    target_prefix = "logs/"
  }

  tags = {
    Name        = "Secure Bucket"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_policy" "enforce_ssl_policy" {
  bucket = aws_s3_bucket.secure_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnforceSSL"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource  = [
          aws_s3_bucket.secure_bucket.arn,
          "${aws_s3_bucket.secure_bucket.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

### Explanation:
1. **`aws_s3_bucket` Resource**:
   - Creates an S3 bucket with private access (`acl = "private"`).
   - Enables server-side encryption using AES256.
   - Activates versioning to track object changes.
   - Configures logging to store access logs in a specified bucket and prefix.
   - Tags are added for identification, including the bucket name, environment, and management tool.

2. **`aws_s3_bucket_policy` Resource**:
   - Attaches a bucket policy that denies any request not using HTTPS.
   - The `Condition` block ensures that the `aws:SecureTransport` key is set to `true`.

### Variables:
Define the variables used in the code (`var.bucket_name`, `var.logging_bucket_name`) in a `variables.tf` file:


variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "logging_bucket_name" {
  description = "The name of the bucket where access logs will be stored"
  type        = string
}

This format matches the requested structure and ensures clarity and maintainability. Let me know if you need further assistance!