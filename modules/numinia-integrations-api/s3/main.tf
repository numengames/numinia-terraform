resource "aws_s3_object" "ecs_upload_env_variables" {
  key    = "integrations-api-variables.env"
  bucket = "ecs.${var.domain_name}"
  source = var.s3_env_variables_file
}