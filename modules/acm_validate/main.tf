terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_acm_certificate" "certificate" {
  validation_method = "EMAIL"
  domain_name       = var.domain_name

  subject_alternative_names = [
    "*.${var.domain_name}",
  ]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "SSL Certificate for ${var.domain_name}"
  }
}

# TODO: Review because it doesn't work as expected
# resource "null_resource" "delete_cname_record" {
#   depends_on = [aws_acm_certificate_validation.ssl_certificate_validation]

#   provisioner "local-exec" {
#     command = <<-EOT
#       aws route53 change-resource-record-sets --hosted-zone-id ${var.zone_id} --change-batch '{
#         "Changes": [
#           {
#             "Action": "DELETE",
#             "ResourceRecordSet": {
#               "Name": "${aws_route53_record.acm_record[*].records.name}",
#               "Type": "CNAME",
#               "TTL": 60,
#               "ResourceRecords": [
#                 {
#                   "Value": "${aws_route53_record.acm_record[*].records.target}"
#                 }
#               ]
#             }
#           }
#         ]
#       }'
#     EOT
#   }
# }