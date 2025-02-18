# Rol para administradores de Kubernetes
resource "aws_iam_role" "eks_admin" {
  name = "${var.cluster_name}-k8s-admin-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = ["arn:aws:iam::${var.aws_account_id}:user/terraform"]
          Service = "eks.amazonaws.com"
        },
      }
    ]
  })

  tags = {
    Name        = "${var.cluster_name}-k8s-admin-role"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_iam_policy" "eks_admin_self_assume" {
  name = "${var.cluster_name}-k8s-admin-self-assume"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Resource = aws_iam_role.eks_admin.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_admin_self_assume" {
  policy_arn = aws_iam_policy.eks_admin_self_assume.arn
  role       = aws_iam_role.eks_admin.name
}

# Política para permitir acceso administrativo a EKS
resource "aws_iam_role_policy" "eks_admin" {
  name = "${var.cluster_name}-k8s-admin-policy"
  role = aws_iam_role.eks_admin.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:*",
          "ec2:DescribeInstances",
          "ec2:DescribeRouteTables",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVolumes",
          "ec2:DescribeVolumesModifications",
          "ec2:DescribeVpcs",
          "iam:ListRoles",
          "iam:GetRole",
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:PassRole",
          "sts:AssumeRole",
          "sts:GetCallerIdentity"
        ]
        Resource = "*"
      }
    ]
  })
}

# Política para permitir que el usuario terraform asuma el rol de administrador
resource "aws_iam_user_policy" "terraform_assume_admin" {
  name = "terraform-assume-k8s-admin"
  user = "terraform"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sts:AssumeRole",
          "sts:GetCallerIdentity",
          "iam:GetRole"
        ]
        Resource = aws_iam_role.eks_admin.arn
      }
    ]
  })
}
