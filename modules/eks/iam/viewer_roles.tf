# Usuario para visualización de Kubernetes
resource "aws_iam_user" "k8s_viewer" {
  name = "k8s-viewer"

  tags = {
    Environment = var.environment
    Role        = "kubernetes-readonly"
  }
}

resource "aws_iam_access_key" "k8s_viewer_key" {
  user = aws_iam_user.k8s_viewer.name
}

# Política de solo lectura para EKS
resource "aws_iam_policy" "eks_read_only" {
  name        = "${var.cluster_name}-eks-read-only"
  description = "Permisos de solo lectura para consultar recursos de EKS"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:DescribeFargateProfile",
          "eks:ListFargateProfiles",
          "eks:ListUpdates",
          "eks:DescribeUpdate",
          "eks:DescribeAddon",
          "eks:ListAddons",
          "eks:AccessKubernetesApi"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "k8s_viewer_readonly" {
  user       = aws_iam_user.k8s_viewer.name
  policy_arn = aws_iam_policy.eks_read_only.arn
}
