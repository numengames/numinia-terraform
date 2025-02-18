variable "domain_name" {
  type        = string
  description = "Domain name for the SSL certificate"
}

variable "validation_method" {
  type        = string
  description = "Certificate validation method. Can be either DNS or EMAIL"
  validation {
    condition     = contains(["DNS", "EMAIL"], var.validation_method)
    error_message = "Validation method must be either DNS or EMAIL"
  }
}

variable "subject_alternative_names" {
  type        = list(string)
  description = "List of alternative domain names for the certificate"
  default     = []
}