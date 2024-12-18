terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.7.3"
}

provider "aws" {
  alias      = "us_east"
  region     = var.us_east_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

provider "aws" {
  region     = var.eu_west_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

module "certificate_manager_us_east" {
  source      = "./modules/acm"
  domain_name = var.domain_name
  providers   = { aws = aws.us_east }
}

module "certificate_manager_eu_west" {
  source      = "./modules/acm"
  domain_name = var.domain_name
}

resource "aws_route53_zone" "route53_domain_zone" {
  name = var.domain_name
}

module "environments" {
  source       = "./environments/production"
  server_name  = var.server_name
  domain_name  = var.domain_name
  zone_id      = aws_route53_zone.route53_domain_zone.zone_id
  github_CI_CD = var.github_CI_CD
  region       = var.eu_west_region

  acm_certificate_arn = {
    us_east : module.certificate_manager_us_east.acm_certificate_arn,
    eu_west : module.certificate_manager_eu_west.acm_certificate_arn,
  }
}
