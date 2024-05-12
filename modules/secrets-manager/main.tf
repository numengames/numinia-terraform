resource "aws_secretsmanager_secret" "github_deploy_secret" {
  name = var.github_secret_name
}

resource "aws_secretsmanager_secret_version" "github_deploy_secret_value" {
  secret_string = jsonencode(var.github_CI_CD)
  secret_id     = aws_secretsmanager_secret.github_deploy_secret.id
}