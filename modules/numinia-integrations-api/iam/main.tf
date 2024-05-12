resource "aws_iam_user" "user" {
  name = "${var.resource_name}-user"
}

resource "aws_iam_access_key" "access_key" {
  user = aws_iam_user.user.name
}

resource "aws_iam_user_policy" "user_policies" {
  name = "${var.resource_name}_policies"
  user = aws_iam_user.user.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ],
        Resource = "*"
      }
    ]
  })
}