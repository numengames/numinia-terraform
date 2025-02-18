variable "eu_west_region" {
  description = "The EU West region to deploy resources"
  type        = string
}

variable "server_name" {
  description = "The name of the server"
  type        = string
}

variable "cluster_config" {
  description = "Configuration for the EKS cluster"
  type        = map(any)
}

variable "node_groups" {
  description = "Configuration for the EKS node groups"
  type        = map(any)
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}
