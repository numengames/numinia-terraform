variable "server_name" {
  type = string
}

variable "domain_name" {
  type = string
}

#######################
### AWS Credentials ###
#######################

variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type = string
}

variable "us_east_region" {
  type    = string
  default = "us-east-1"
}

variable "eu_west_region" {
  type    = string
  default = "eu-west-1"
}

#######################
# Github deployements #
#######################

variable "github_CI_CD" {
  type = map(string)
}