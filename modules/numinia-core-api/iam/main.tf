resource "aws_iam_user" "user" {
  name = "${var.resource_name}-user"
}

resource "aws_iam_access_key" "access_key" {
  user = aws_iam_user.user.name
}