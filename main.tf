provider "aws" {
  region = "us-east-1"
}

# 1. Create the secret
resource "aws_secretsmanager_secret" "example" {
  name = "example"
}

# 2. IAM Policy Document allowing access to the secret
data "aws_iam_policy_document" "example" {
  statement {
    sid    = "AllowReadSecret"
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue"
    ]

    resources = [
      aws_secretsmanager_secret.example.arn
    ]
  }
}

# 3. IAM Policy from the policy document
resource "aws_iam_policy" "example" {
  name        = "AllowReadExampleSecret"
  description = "Allows GetSecretValue on example secret"
  policy      = data.aws_iam_policy_document.example.json
}

# 4. Create the IAM Role
resource "aws_iam_role" "iam_role" {
  name = "example-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com" # or whatever AWS service/principal you want
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# 5. Attach the policy to the role
resource "aws_iam_role_policy_attachment" "secret_access" {
  role       = aws_iam_role.iam_role.name
  policy_arn = aws_iam_policy.example.arn
}
