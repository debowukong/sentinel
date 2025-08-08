provider "aws" {
  region = "us-east-1" # Change as needed
}

resource "aws_iam_policy" "acm_private_ca_vpc_endpoint_policy" {
  name        = "acm-pca-vpc-endpoint-policy"
  description = "Policy that restricts ACM PCA actions to only be allowed through the VPC endpoint"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Deny"
        Action   = [
          "acm-pca:CreateCertificateAuthority",
          "acm-pca:DescribeCertificateAuthority",
          "acm-pca:DeleteCertificateAuthority",
          "acm-pca:GetCertificateAuthorityCertificate",
          "acm-pca:ListCertificateAuthorities",
          "acm-pca:IssueCertificate",
          "acm-pca:GetCertificate",
          "acm-pca:RevokeCertificate",
          "acm-pca:ListPermissions",
          "acm-pca:CreatePermission",
          "acm-pca:DeletePermission"
        ]
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "aws:SourceVpce" = [
              "vpce-0abcd1234efgh5678",  # Approved VPC endpoint ID
              "vpce-0abcd1234ijkl5678"   # Approved VPC endpoint ID
            ]
          }
        }
        Sid = "DenyACMPCAActionsOutsideVPCEndpoint"
      }
    ]
  })
}