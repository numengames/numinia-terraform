resource "aws_iam_policy" "github_policy" {
  name        = "github-policy"
  description = "A policy to allow reading a github user & password from secret manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
        ]
        Effect   = "Allow"
        Resource = "${var.github_secret_manager_arn}"
      },
    ]
  })
}

resource "aws_iam_role" "ecsTaskExecutionRoleGithub" {
  name = "ecsTaskExecutionRoleGithub"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_policy_attachment" {
  role       = aws_iam_role.ecsTaskExecutionRoleGithub.name
  policy_arn = aws_iam_policy.github_policy.arn
}

resource "aws_iam_role_policy_attachment" "aws_s3_read_only_access_attachment" {
  role       = aws_iam_role.ecsTaskExecutionRoleGithub.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "taskExecutionRolePolicy_attachment" {
  role       = aws_iam_role.ecsTaskExecutionRoleGithub.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}