data "aws_iam_user" "terraform" {
  user_name = "terraform"
}

# Cluster EKS
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.33.1"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  # Control plane
  cluster_endpoint_public_access = true

  # Logging configuration
  cluster_enabled_log_types = [
    var.cluster_logging.api ? "api" : null,
    var.cluster_logging.audit ? "audit" : null,
    var.cluster_logging.authenticator ? "authenticator" : null,
    var.cluster_logging.controllerManager ? "controllerManager" : null,
    var.cluster_logging.scheduler ? "scheduler" : null,
  ]

  # AWS Auth configuration
  authentication_mode = var.authentication_mode
  access_entries = {
    terraform_user = {
      kubernetes_groups = var.terraform_user_kubernetes_groups
      principal_arn     = data.aws_iam_user.terraform.arn
      type              = "STANDARD"
    }
  }

  # IAM Roles
  create_iam_role = false
  iam_role_arn    = var.cluster_role_arn

  # Node groups configuration
  eks_managed_node_groups = {
    for name, config in var.node_groups : name => merge({
      min_size       = config.min_size
      max_size       = config.max_size
      desired_size   = config.desired_size != null ? config.desired_size : config.min_size
      instance_types = [config.instance_type]
      capacity_type  = config.capacity_type

      iam_role_arn = var.nodes_role_arn

      labels = merge({
        Environment = var.environment
        ManagedBy   = "terraform"
        OS          = "linux"
        Arch        = "amd64"
      }, config.labels)

      taints = config.taints

      tags = {
        "k8s.io/cluster-autoscaler/enabled"             = "true"
        "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
        Environment                                     = var.environment
        ManagedBy                                       = "terraform"
      }

      update_config = {
        max_unavailable_percentage = var.node_group_update_max_unavailable_percentage
      }

      # Configuración del disco
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size = try(config.storage_config.volume_size, 50)
            volume_type = try(config.storage_config.volume_type, "gp3")
            encrypted   = try(config.storage_config.encrypted, true)
          }
        }
      }

      # Kubelet configuration
      kubelet_config = {
        container_log_max_size  = try(config.kubelet_config.container_log_max_size, "10Mi")
        container_log_max_files = try(config.kubelet_config.container_log_max_files, 5)
        cpu_cfs_quota_enabled   = try(config.kubelet_config.cpu_cfs_quota_enabled, true)
        max_pods                = try(config.kubelet_config.max_pods, 70)
        system_reserved = try(config.kubelet_config.system_reserved, {
          cpu    = "100m"
          memory = "100Mi"
        })
      }

      # Launch template configuration
      create_launch_template      = true
      launch_template_name        = try(config.launch_template.name, null)
      launch_template_description = try(config.launch_template.description, "Launch template for ${var.cluster_name} - ${name}")
      ebs_optimized               = try(config.launch_template.ebs_optimized, true)
      monitoring_enabled          = try(config.launch_template.monitoring_enabled, true)
      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = try(config.launch_template.metadata_http_tokens, "required")
        http_put_response_hop_limit = try(config.launch_template.metadata_http_put_hop_limit, 2)
      }

      # Lifecycle policy
      create_before_destroy = true
    })
  }

  # Add-ons
  cluster_addons = merge(
    var.enable_addons.coredns ? {
      coredns = {
        most_recent = true
        preserve    = true
        configuration_values = jsonencode({
          computeType = var.coredns_compute_type
          resources   = var.coredns_resources
        })
      }
    } : {},
    var.enable_addons.kube_proxy ? {
      kube-proxy = {
        most_recent = true
        preserve    = true
      }
    } : {},
    var.enable_addons.vpc_cni ? {
      vpc-cni = {
        most_recent = true
        preserve    = true
        configuration_values = jsonencode({
          env = {
            ENABLE_PREFIX_DELEGATION = tostring(var.vpc_cni_config.enable_prefix_delegation)
            WARM_PREFIX_TARGET       = var.vpc_cni_config.warm_prefix_target
            ENABLE_POD_ENI           = tostring(var.vpc_cni_config.enable_pod_eni)
          }
        })
      }
    } : {},
    var.enable_addons.efs_csi ? {
      aws-efs-csi-driver = {
        most_recent = var.efs_csi_config.version == "latest"
        version     = var.efs_csi_config.version != "latest" ? var.efs_csi_config.version : null
        preserve    = true
        configuration_values = jsonencode({
          controller = {
            resources    = var.efs_csi_config.controller.resources
            replicaCount = var.efs_csi_config.controller.replica_count
          }
        })
        service_account_role_arn = var.efs_csi_role_arn
      }
    } : {},
    var.enable_addons.secrets_store_csi ? {
      secrets-store-csi-driver = {
        most_recent = var.secrets_store_csi_config.version == "latest"
        version     = var.secrets_store_csi_config.version != "latest" ? var.secrets_store_csi_config.version : null
        preserve    = true
        configuration_values = jsonencode({
          controller = {
            resources    = var.secrets_store_csi_config.controller.resources
            replicaCount = var.secrets_store_csi_config.controller.replica_count
          }
          node = {
            resources = var.secrets_store_csi_config.node.resources
          }
          rotationPollInterval = var.secrets_store_csi_config.rotation_poll_interval
          enableRotation       = var.secrets_store_csi_config.enable_rotation
          providerInstall      = var.secrets_store_csi_config.provider_install
        })
      }
    } : {}
  )

  # Enable IRSA for CSI Drivers if any is enabled
  enable_irsa = var.enable_addons.efs_csi || var.enable_addons.secrets_store_csi

  # Tags
  tags = {
    Environment                                 = var.environment
    ManagedBy                                   = "terraform"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    KubernetesVersion                           = var.cluster_version
  }
}

# Security Groups
resource "aws_security_group" "eks_cluster" {
  name        = "${var.cluster_name}-cluster"
  description = "Security group for EKS cluster control plane"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                                        = "${var.cluster_name}-cluster"
    Environment                                 = var.environment
    ManagedBy                                   = "terraform"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "cluster_ingress" {
  description              = "Allow worker nodes to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_nodes.id
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group" "eks_nodes" {
  name        = "${var.cluster_name}-nodes"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                                        = "${var.cluster_name}-nodes"
    Environment                                 = var.environment
    ManagedBy                                   = "terraform"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_security_group_rule" "nodes_internal" {
  description              = "Allow nodes to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_nodes.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "nodes_cluster_inbound" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_cluster.id
  to_port                  = 65535
  type                     = "ingress"
}
