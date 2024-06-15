# Videonia Terraform

This repository contains the Terraform configuration for Videonia's infrastructure.

## Initial Requirements

Before running the Terraform project, ensure you have the following prerequisites:

1. **Terraform Installation**:
   - Install Terraform from the [official website](https://www.terraform.io/downloads.html).

2. **AWS CLI Installation**:
   - Install the AWS CLI from the [official website](https://aws.amazon.com/cli/).

3. **AWS Configuration**:
   - Configure your AWS credentials provided by the lead of the cloud services by running:
     ```sh
     aws configure
     ```
   - Follow the prompts to enter your AWS Access Key ID, Secret Access Key, region, and output format.

4. **Clone the Repository**:
   ```sh
   git clone https://github.com/numengames/numinia-terraform.git
   cd numinia-terraform
   ```

5. **Configure Variables**:
   - Create a `terraform.tfvars` file and define the necessary variable values required by `variables.tf`.

6. **Initialize Terraform**:
   - Run the following command to initialize the Terraform working directory:
     ```sh
     terraform init
     ```

7. **Plan and Apply**:
   - To see the changes that will be made, run:
     ```sh
     terraform plan
     ```
   - To apply the changes, run:
     ```sh
     terraform apply
     ```

## Project Structure

### Main Files

- **.terraform/**: Terraform configuration and state files.
- **main.tf**: Main Terraform configuration file.
- **variables.tf**: Variable definitions.
- **terraform.tfvars**: Variable values.
- **terraform.tfstate.backup**: Backup of the state file.
- **.gitignore**: Git ignore file.
- **.gitlab-ci.yml**: GitLab CI/CD configuration.
- **.terraform.lock.hcl**: Provider version lock file.

### Directories

- **environments/production/**: Production environment configuration.
- **modules/**: Reusable Terraform modules.

## Modules

- **acm**: Manages AWS Certificate Manager (ACM) resources for provisioning and managing SSL/TLS certificates.
- **acm_validate**: Handles the validation of ACM certificates, typically through DNS validation.
- **cloudfront**: Configures Amazon CloudFront distributions for content delivery.
- **ecs_cluster**: Sets up Amazon ECS (Elastic Container Service) clusters for running containerized applications.
- **iam**: Manages AWS Identity and Access Management (IAM) resources, including users, roles, and policies.
- **route53**: Configures Amazon Route 53 for DNS management.
- **s3**: Manages Amazon S3 buckets for object storage.
- **secrets-manager**: Manages AWS Secrets Manager for storing and retrieving sensitive information.
- **ses**: Configures Amazon Simple Email Service (SES) for sending and receiving emails.
- **videonia-core**: Custom module for managing core services specific to Videonia.
- **vpc**: Sets up Amazon Virtual Private Cloud (VPC) resources for network isolation and management.