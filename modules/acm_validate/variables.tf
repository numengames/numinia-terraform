variable "acm_validation_records" {
  description = "Los registros de validación del certificado SSL."
  type = list(object({
    name  = string
    type  = string
    value = string
  }))
}

variable "domain_name" {
  type = string
}

variable "zone_id" {
  type = string
}

variable "certificate_arn" {
  type = string
}

variable "validation_record_fqdn" {
  type = set(string)
}