# IAM Role para el Secret Manager y EFS access
resource "aws_iam_role" "secret_manager_efs" {
  name = "${var.cluster_name}-secret-manager-efs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${var.aws_account_id}:oidc-provider/${replace(var.cluster_oidc_issuer_url, "https://", "")}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(var.cluster_oidc_issuer_url, "https://", "")}:sub" : "system:serviceaccount:${var.app_namespace}:aws-secret-manager-sa"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${var.cluster_name}-secret-manager-efs-role"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Política personalizada para acceso a Secrets Manager
resource "aws_iam_policy" "secret_manager_access" {
  name        = "${var.cluster_name}-secret-manager-policy"
  description = "Policy for accessing secrets in AWS Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecrets"
        ]
        Resource = [
          "arn:aws:secretsmanager:*:${var.aws_account_id}:secret:hyperfy2-*",
          "arn:aws:secretsmanager:*:${var.aws_account_id}:secret:github-*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          StringLike = {
            "kms:RequestAlias" : "alias/aws/secretsmanager"
          }
        }
      }
    ]
  })
}

# Política personalizada para acceso a EFS
resource "aws_iam_policy" "efs_access" {
  name        = "${var.cluster_name}-efs-access-policy"
  description = "Policy for accessing EFS file system"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:DescribeFileSystems",
          "elasticfilesystem:DescribeMountTargets",
          "elasticfilesystem:DescribeMountTargetSecurityGroups"
        ]
        Resource = "arn:aws:elasticfilesystem:*:${var.aws_account_id}:file-system/*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/Environment" : var.environment,
            "aws:ResourceTag/ManagedBy" : "terraform"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "elasticfilesystem:CreateAccessPoint",
          "elasticfilesystem:DeleteAccessPoint",
          "elasticfilesystem:DescribeAccessPoints"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attachments de las políticas al rol
resource "aws_iam_role_policy_attachment" "secret_manager_attachment" {
  policy_arn = aws_iam_policy.secret_manager_access.arn
  role       = aws_iam_role.secret_manager_efs.name
}

resource "aws_iam_role_policy_attachment" "efs_access_attachment" {
  policy_arn = aws_iam_policy.efs_access.arn
  role       = aws_iam_role.secret_manager_efs.name
}
