variable "domain_name" {
  type        = string
  description = "The domain name to use for bucket names"
}

variable "environment" {
  type        = string
  description = "Environment name for tagging (e.g., production, staging)"
}

variable "project_name" {
  type        = string
  description = "Project name for tagging"
}

variable "dev_storage_retention_days" {
  type        = number
  description = "Number of days to retain files in the dev storage bucket"
  default     = 30
}

variable "allowed_origins" {
  type        = list(string)
  description = "List of allowed origins for CORS configuration of the statics bucket"
  default     = ["*"]
}