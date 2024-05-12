resource "aws_ses_domain_identity" "domain_identity" {
  domain = var.domain_name
}

resource "aws_ses_domain_dkim" "domain_dkim" {
  domain = aws_ses_domain_identity.domain_identity.domain
}

resource "aws_ses_domain_identity_verification" "verification" {
  domain = aws_ses_domain_identity.domain_identity.domain
}