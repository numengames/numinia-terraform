variable "server_name" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "zone_id" {}

variable "region" {
  type = string
}

variable "acm_certificate_arn" {
  type = object({
    us_east = string
    eu_west = string
  })
}

#######################
# Github deployements #
#######################

variable "github_CI_CD" {
  type = map(string)
}

variable "github_secret_name" {
  type    = string
  default = "github-deploy-key-secret-1"
}

######################
# ECS Specifications #
######################

variable "cluster_capacity" {
  type = object({
    max     = number
    min     = number
    desired = number
  })

  default = {
    max : 2,
    min : 1,
    desired : 1
  }
}
