# Numinia Terraform

This repository contains a comprehensive Terraform-based infrastructure that deploys various modules to manage AWS resources. The project covers networking, certificate management, storage, secrets management, and an EKS (Elastic Kubernetes Service) cluster with associated resources.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Main Modules](#main-modules)
- [Getting Started](#getting-started)
- [Configuration Management](#configuration-management)
- [State Management](#state-management)
- [Variables and Configuration](#variables-and-configuration)
- [Workflow and Deployment](#workflow-and-deployment)
- [Contributing](#contributing)
- [License](#license)
- [Additional Notes](#additional-notes)

## Prerequisites

- **Terraform:** Version `>= 1.7.3`
- **AWS CLI:** Configured with the necessary credentials
- **AWS Permissions:** Sufficient rights to create and manage resources (VPC, S3, ACM, EKS, IAM, etc.)
- **Git:** For cloning and managing the repository

## Project Structure

The repository is organized as follows:

```
├── environments
│   └── production
│       ├── main.tf
│       └── variables.tf
├── main.tf
├── modules
│   ├── acm
│   │   ├── main.tf
│   │   ├── output.tf
│   │   └── variables.tf
│   ├── eks
│   │   ├── cluster
│   │   │   ├── main.tf
│   │   │   ├── output.tf
│   │   │   └── variables.tf
│   │   ├── iam
│   │   │   ├── admin_roles.tf
│   │   │   ├── cluster_autoscaler.tf
│   │   │   ├── efs_csi.tf
│   │   │   ├── load_balancer_controller_role.tf
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   ├── secret_manager_efs_role.tf
│   │   │   ├── variables.tf
│   │   │   └── viewer_roles.tf
│   │   ├── main.tf
│   │   ├── nlb.tf
│   │   ├── output.tf
│   │   ├── storage.tf
│   │   └── variables.tf
│   ├── secrets-manager
│   │   ├── main.tf
│   │   ├── output.tf
│   │   ├── policies
│   │   │   ├── main.tf
│   │   │   ├── output.tf
│   │   │   └── variables.tf
│   │   └── variables.tf
│   ├── storage
│   │   ├── cloudfront
│   │   │   ├── main.tf
│   │   │   ├── output.tf
│   │   │   └── variables.tf
│   │   ├── main.tf
│   │   ├── policies
│   │   │   ├── cloudfront
│   │   │   │   ├── cache
│   │   │   │   │   ├── main.tf
│   │   │   │   │   ├── output.tf
│   │   │   │   │   └── variables.tf
│   │   │   │   └── headers
│   │   │   │       ├── main.tf
│   │   │   │       ├── output.tf
│   │   │   │       └── variables.tf
│   │   │   └── s3
│   │   │       ├── bucket
│   │   │       │   ├── main.tf
│   │   │       │   └── variables.tf
│   │   │       └── cloudfront-access
│   │   │           ├── main.tf
│   │   │           └── variables.tf
│   │   ├── s3
│   │   │   ├── main.tf
│   │   │   ├── output.tf
│   │   │   └── variables.tf
│   │   └── variables.tf
│   └── vpc
│       ├── main.tf
│       ├── output.tf
│       ├── security-groups
│       │   ├── main.tf
│       │   ├── output.tf
│       │   └── variables.tf
│       └── variables.tf
├── package-lock.json
├── terraform.lock.hcl
├── terraform.tfstate
├── terraform.tfstate.backup
├── terraform.tfvars.example
└── variables.tf
```

> **Note:** Each module is designed to be reusable and configurable via variables. For example, the **EKS** module lets you configure the cluster, node groups, IAM roles, and add-ons.

## Main Modules

### VPC
- **Purpose:** Create the Virtual Private Cloud (VPC) along with subnets, internet gateways, routing tables, and tagging for Kubernetes integration.
- **Files:** `modules/vpc/main.tf`, `modules/vpc/output.tf`, `modules/vpc/variables.tf`

### ACM (Certificate Manager)
- **Purpose:** Manage issuance and validation of SSL certificates using AWS ACM.
- **Files:** `modules/acm/main.tf`, `modules/acm/output.tf`, `modules/acm/variables.tf`

### Storage
- **Purpose:** Set up S3 buckets for various purposes (storage, logs, static assets), configure CloudFront for content distribution, and enforce policies such as encryption and versioning.
- **Files:** Includes submodules like `s3`, `cloudfront`, and `policies` (for S3, CloudFront cache, and headers).

### Secrets Manager
- **Purpose:** Create and manage secrets in AWS Secrets Manager along with proper access policies.
- **Files:** `modules/secrets-manager/main.tf`, `modules/secrets-manager/output.tf`, `modules/secrets-manager/variables.tf`

### EKS
- **Purpose:** Deploy and configure an AWS-managed Kubernetes cluster (EKS) including:
  - Node groups with autoscaling capabilities
  - IAM roles and policies
  - Network Load Balancer integration
  - Organization-based EFS storage
  - Add-ons (CoreDNS, VPC CNI, etc.)
- **Files:** Located under `modules/eks/` and split into submodules for the cluster, IAM, NLB, storage, etc.

## Configuration Management

The project uses a three-tier approach to manage configuration:

### 1. AWS Secrets Manager
Sensitive and environment-specific configurations are stored in AWS Secrets Manager:
- AWS credentials
- Domain and server names
- EKS cluster configuration
- Node groups configuration

The secret structure should follow this format:
```json
{
  "aws_access_key": "your-access-key",
  "aws_secret_key": "your-secret-key",
}
```

### 2. Terraform State Management
The state is managed remotely using:
- **S3 Bucket**: For state storage
- **DynamoDB Table**: For state locking
- **Encryption**: All state data is encrypted at rest

The backend configuration is defined in `main.tf`:
```hcl
terraform {
  backend "s3" {
    bucket         = "numinia-terraform-state"
    key            = "environments/production/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "numinia-terraform-locks"
    encrypt        = true
  }
}
```

### 3. Local Configuration
Local configuration is limited to:
- Environment selection
- Feature flags
- AWS Secrets Manager reference
- Organization list for EFS storage

Example `terraform.tfvars`:
```hcl
# Environment Configuration
environment = "production"

# AWS Secrets Manager Configuration
secret_name = "numinia/terraform/production"

# Feature Flags
enable_certificate_manager = false
enable_storage            = false
enable_route53           = false

# Organizations Configuration
organizations = ["XXXX"]  # Add more organizations as needed
```

## Storage Management

### EFS Storage
The project supports multiple EFS file systems, one per organization:

- **Organization-based Storage:** Each organization gets its own dedicated EFS
- **Automatic Encryption:** All EFS volumes are encrypted by default
- **Backup Policy:** Automatic backups enabled for all EFS volumes
- **Multi-AZ:** Mount targets in multiple availability zones
- **Security:** Dedicated security group with proper NFS access rules

To add a new organization's storage:
1. Add the organization to the `organizations` list in your `terraform.tfvars`
2. Apply the changes with Terraform
3. The new EFS will be automatically created with all necessary configurations

## Getting Started

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/your_username/your_project.git
   cd your_project
   ```

2. **Set Up AWS Secrets:**
   - Create a secret in AWS Secrets Manager with the required configuration
   - Ensure the secret follows the structure shown above
   - Note the secret name for the next step

3. **Configure Local Variables:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
   Edit `terraform.tfvars` to set:
   - Environment name
   - Secret name
   - Feature flags as needed

4. **Initialize Terraform:**
   ```bash
   terraform init
   ```

5. **Validate the Configuration:**
   ```bash
   terraform validate
   ```

6. **Plan the Deployment:**
   ```bash
   terraform plan
   ```

7. **Apply the Infrastructure:**
   ```bash
   terraform apply
   ```

## Variables and Configuration

Each module contains its own `variables.tf` file that defines the required inputs. For example:

- **VPC:** Variables for CIDR ranges, names, and region
- **ACM:** Variables such as `domain_name`, `validation_method`, and `subject_alternative_names`
- **EKS:** Cluster configuration, subnet details, Kubernetes version, IAM roles, node groups, and add-on settings

Be sure to check the internal documentation of each module for details on each variable and its default values.

## Workflow and Deployment

The project is designed to be modular and scalable. You can:

- **Deploy Individual Modules:** Use a single module if you only need to deploy the networking or the EKS cluster
- **Manage Environments:** Each environment (e.g., production) has its own folder with configuration files and variable definitions
- **Integrate with CI/CD:** Easily integrate the repository with CI/CD pipelines (e.g., GitHub Actions, GitLab CI) to automate deployments

## Contributing

Contributions are welcome! Please see the `CONTRIBUTING.md` file for details on our workflow, guidelines, and how to submit pull requests or report issues.

## License

This project is distributed under the MIT License. See the `LICENSE` file for details.

## Additional Notes

- **Security:** Ensure that sensitive files (like those containing AWS credentials) are not committed to the repository. Use an appropriate `.gitignore`
- **Updates:** It is recommended to keep the AWS provider and Terraform version updated to benefit from new features and security patches
- **Further Documentation:** For more details on using Terraform and the individual modules, consult the Terraform documentation

Thank you for using this project! If you have any questions or suggestions, please open an issue or submit a pull request.