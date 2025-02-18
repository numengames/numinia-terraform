variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.32"
  validation {
    condition     = can(regex("^1\\.(3[0-2])$", var.cluster_version))
    error_message = "Cluster version must be between 1.30 and 1.32"
  }
}

variable "vpc_id" {
  description = "ID of the VPC where the cluster will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where the cluster will be created"
  type        = list(string)
}

variable "environment" {
  description = "Environment name (e.g., production, staging)"
  type        = string
}

variable "cluster_role_arn" {
  description = "ARN of the IAM role for the EKS cluster"
  type        = string
}

variable "nodes_role_arn" {
  description = "ARN of the IAM role for the EKS worker nodes"
  type        = string
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
    storage_config = optional(object({
      volume_size = optional(number, 50)
      volume_type = optional(string, "gp3")
      encrypted   = optional(bool, true)
    }), {})
    kubelet_config = optional(object({
      container_log_max_size  = optional(string, "10Mi")
      container_log_max_files = optional(number, 5)
      cpu_cfs_quota_enabled   = optional(bool, true)
      max_pods                = optional(number, 70)
      system_reserved = optional(object({
        cpu    = optional(string, "100m")
        memory = optional(string, "100Mi")
      }), {})
    }), {})
    launch_template = optional(object({
      name                        = optional(string)
      description                 = optional(string)
      ebs_optimized               = optional(bool, true)
      monitoring_enabled          = optional(bool, true)
      enable_imdsv2               = optional(bool, true)
      metadata_http_tokens        = optional(string, "required")
      metadata_http_put_hop_limit = optional(number, 2)
    }), {})
  }))
}

variable "node_group_update_max_unavailable_percentage" {
  description = "Maximum percentage of nodes that can be unavailable during node group updates"
  type        = number
  default     = 33
  validation {
    condition     = var.node_group_update_max_unavailable_percentage >= 0 && var.node_group_update_max_unavailable_percentage <= 100
    error_message = "The max unavailable percentage must be between 0 and 100"
  }
}

variable "terraform_user_kubernetes_groups" {
  description = "List of Kubernetes groups to assign to the terraform user"
  type        = list(string)
  default     = ["cluster-admin"]
}

variable "authentication_mode" {
  description = "Authentication mode for the EKS cluster"
  type        = string
  default     = "API_AND_CONFIG_MAP"
}

variable "coredns_compute_type" {
  description = "Compute type for CoreDNS addon (e.g., EC2, Fargate)"
  type        = string
  default     = "EC2"
}

variable "coredns_resources" {
  description = "Resource limits and requests for CoreDNS addon"
  type = object({
    limits = object({
      cpu    = string
      memory = string
    })
    requests = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    limits = {
      cpu    = "250m"
      memory = "256Mi"
    }
    requests = {
      cpu    = "100m"
      memory = "128Mi"
    }
  }
}

variable "vpc_cni_config" {
  description = "Configuration options for VPC CNI addon"
  type = object({
    enable_prefix_delegation = optional(bool, true)
    warm_prefix_target       = optional(string, "1")
    enable_pod_eni           = optional(bool, true)
  })
  default = {
    enable_prefix_delegation = true
    warm_prefix_target       = "1"
    enable_pod_eni           = true
  }
}

variable "enable_addons" {
  description = "Feature flags to enable/disable EKS addons"
  type = object({
    coredns           = optional(bool, true)
    kube_proxy        = optional(bool, true)
    vpc_cni           = optional(bool, true)
    efs_csi           = optional(bool, true)
    secrets_store_csi = optional(bool, true)
  })
  default = {
    coredns           = true
    kube_proxy        = true
    vpc_cni           = true
    efs_csi           = true
    secrets_store_csi = true
  }
}

variable "efs_csi_config" {
  description = "Configuration for EFS CSI driver addon"
  type = object({
    version = optional(string, "latest")
    controller = optional(object({
      resources = optional(object({
        limits = optional(object({
          cpu    = optional(string, "100m")
          memory = optional(string, "128Mi")
        }), {})
        requests = optional(object({
          cpu    = optional(string, "100m")
          memory = optional(string, "128Mi")
        }), {})
      }), {})
      replica_count = optional(number, 2)
    }), {})
  })
  default = {
    version = "latest"
    controller = {
      resources = {
        limits = {
          cpu    = "100m"
          memory = "128Mi"
        }
        requests = {
          cpu    = "100m"
          memory = "128Mi"
        }
      }
      replica_count = 2
    }
  }
}

variable "secrets_store_csi_config" {
  description = "Configuration for Secrets Store CSI driver addon"
  type = object({
    version = optional(string, "v1.3.4")
    controller = optional(object({
      resources = optional(object({
        limits = optional(object({
          cpu    = optional(string, "100m")
          memory = optional(string, "128Mi")
        }), {})
        requests = optional(object({
          cpu    = optional(string, "50m")
          memory = optional(string, "64Mi")
        }), {})
      }), {})
      replica_count = optional(number, 2)
    }), {})
    node = optional(object({
      resources = optional(object({
        limits = optional(object({
          cpu    = optional(string, "100m")
          memory = optional(string, "128Mi")
        }), {})
        requests = optional(object({
          cpu    = optional(string, "50m")
          memory = optional(string, "64Mi")
        }), {})
      }), {})
    }), {})
    rotation_poll_interval = optional(string, "2m")
    enable_rotation        = optional(bool, true)
    provider_install       = optional(bool, true)
  })
  default = {
    version = "v1.3.4"
    controller = {
      resources = {
        limits = {
          cpu    = "100m"
          memory = "128Mi"
        }
        requests = {
          cpu    = "50m"
          memory = "64Mi"
        }
      }
      replica_count = 2
    }
    node = {
      resources = {
        limits = {
          cpu    = "100m"
          memory = "128Mi"
        }
        requests = {
          cpu    = "50m"
          memory = "64Mi"
        }
      }
    }
    rotation_poll_interval = "2m"
    enable_rotation        = true
    provider_install       = true
  }
}

variable "cluster_logging" {
  description = "Enable/disable control plane logging components"
  type = object({
    api               = bool
    audit             = bool
    authenticator     = bool
    controllerManager = bool
    scheduler         = bool
  })
  default = {
    api               = true
    audit             = true
    authenticator     = true
    controllerManager = true
    scheduler         = true
  }
}

variable "create_iam_role" {
  description = "Whether to create the IAM role for the EKS cluster"
  type        = bool
  default     = true
}

variable "efs_csi_role_arn" {
  description = "ARN of the IAM role for the EFS CSI driver"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}
