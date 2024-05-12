output "github_secret_manager_arn" {
  description = "Export the ARN of the github credentials secret"
  value       = aws_secretsmanager_secret.github_deploy_secret.arn
}