variable "vpc_id" {
  description = "ID of the VPC where the security groups will be created"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC, used for tagging and naming resources"
  type        = string
} 