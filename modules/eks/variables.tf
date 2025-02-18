variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.32"
}

variable "vpc_id" {
  description = "ID of the VPC where the cluster will be created"
  type        = string
}

variable "vpc_subnet" {
  description = "Subnet information for the VPC"
  type = object({
    id_a = string
    id_b = string
  })
}

variable "region" {
  description = "AWS region where the cluster will be created"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., production, staging)"
  type        = string
}

variable "cluster_config" {
  description = "Configuration for the EKS cluster resources"
  type = object({
    max_cpu     = string
    max_memory  = string
    max_pods    = number
    max_storage = string
  })
}

variable "node_groups" {
  description = "Configuration for EKS managed node groups"
  type = map(object({
    instance_type = string
    min_size      = number
    max_size      = number
    desired_size  = optional(number)
    capacity_type = optional(string, "SPOT")
    labels        = optional(map(string), {})
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
  }))
}
