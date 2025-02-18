# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2024-03-20

### Added
- Initial release of Numinia Terraform infrastructure
- Core AWS infrastructure modules:
  - VPC module with networking setup
  - ACM module for SSL certificate management
  - Storage module with S3 and CloudFront integration
  - Secrets Manager module for secure secrets handling
  - EKS module for Kubernetes cluster management
- Environment-specific configurations
- Comprehensive documentation
- Contributing guidelines
- MIT License

### Infrastructure Features
- Multi-environment support through workspace management
- Modular architecture for easy customization
- Security-first approach with proper IAM roles and policies
- Scalable EKS cluster setup with autoscaling capabilities
- Integrated storage solution with CloudFront CDN
- Automated SSL certificate management

[Unreleased]: https://github.com/numengames/numinia-terraform/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/numengames/numinia-terraform/releases/tag/v1.0.0