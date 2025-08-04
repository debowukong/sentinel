data "aws_caller_identity" "current" {}

resource "aws_backup_vault" "example" {
  name = "example"
}

data "aws_iam_policy_document" "example" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }

    actions = [
      "backup:DescribeBackupVault",
      "backup:DeleteBackupVault",
      "backup:PutBackupVaultAccessPolicy",
      "backup:DeleteBackupVaultAccessPolicy",
      "backup:GetBackupVaultAccessPolicy",
      "backup:StartBackupJob",
      "backup:GetBackupVaultNotifications",
      "backup:PutBackupVaultNotifications",
    ]

    resources = [aws_backup_vault.example.arn]

    # Adding conditions to enforce security best practices
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["true"] # Ensure requests are made over HTTPS
    }

    condition {
      test     = "StringEqualsIfExists"
      variable = "aws:RequestTag/Environment"
      values   = ["Production"] # Ensure actions are tagged with 'Production' environment
    }
  }
}

resource "aws_backup_vault_policy" "example" {
  backup_vault_name = aws_backup_vault.example.name
  policy            = data.aws_iam_policy_document.example.json
}