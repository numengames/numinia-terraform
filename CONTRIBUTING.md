# Contributing to Numinia Terraform

Thank you for considering contributing to the Numinia Terraform project! We welcome contributions from everyone. This document provides guidelines to help you get started.

## Table of Contents

- [How to Contribute](#how-to-contribute)
- [Development Setup](#development-setup)
- [Making Changes](#making-changes)
- [Code Standards](#code-standards)
- [Testing](#testing)
- [Pull Request Process](#pull-request-process)
- [Code of Conduct](#code-of-conduct)

## How to Contribute

### Reporting Issues

If you find a bug or have a feature request:
1. Check if the issue already exists in the [Issues](https://github.com/numengames/numinia-terraform/issues) section
2. If not, create a new issue with:
   - Clear description of the problem
   - Steps to reproduce
   - Expected vs actual behavior
   - Your environment details (Terraform version, AWS provider version, etc.)

### Development Setup

1. **Prerequisites:**
   - Terraform (>= 1.7.3)
   - AWS CLI configured with necessary credentials
   - Git

2. **Fork and Clone:**
   ```sh
   git clone https://github.com/numengames/numinia-terraform.git
   cd numinia-terraform
   ```

3. **Set Up Development Environment:**
   - Configure AWS credentials
   - Copy `terraform.tfvars.example` to `terraform.tfvars`
   - Set required variables in your `terraform.tfvars`

## Making Changes

1. **Create a Branch:**
   ```sh
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/your-bugfix-name
   ```

2. **Implement Changes:**
   - Follow the project structure as outlined in the README
   - Maintain modularity in the code
   - Update documentation as needed
   - Add tests for new features

3. **Commit Guidelines:**
   ```sh
   git add .
   git commit -m "type(scope): description"
   ```
   Types: feat, fix, docs, style, refactor, test, chore
   Example: `feat(eks): add support for custom node groups`

4. **Push Changes:**
   ```sh
   git push origin feature/your-feature-name
   ```

## Code Standards

### Terraform Style Guide

- Use consistent naming conventions:
  - Resources: `<provider>_<type>_<name>`
  - Variables: `<module>_<description>`
  - Outputs: `<resource>_<attribute>`
- Format code using `terraform fmt`
- Document all variables and outputs
- Use workspaces for environment management

### Documentation

- Update module README files when adding new features
- Include usage examples for new modules
- Document all variables, outputs, and dependencies

## Testing

Before submitting a pull request:

1. **Local Testing:**
   ```sh
   terraform init
   terraform validate
   terraform plan
   ```

2. **Security Checks:**
   - Run security scanning tools
   - Check for exposed credentials
   - Verify AWS resource policies

## Pull Request Process

1. **Create Pull Request:**
   - Provide clear description of changes
   - Reference related issues
   - Include test results
   - Update documentation

2. **Review Process:**
   - Address reviewer comments
   - Update code as needed
   - Ensure CI/CD checks pass

3. **Merge Requirements:**
   - Approval from at least one maintainer
   - All discussions resolved
   - CI/CD checks passing
   - Documentation updated

## Code of Conduct

We are committed to providing a welcoming and inclusive environment. All participants must adhere to our Code of Conduct:

- Use welcoming and inclusive language
- Be respectful of differing viewpoints
- Accept constructive criticism
- Focus on what is best for the community
- Show empathy towards other community members

## License

By contributing to Numinia Terraform, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to Numinia Terraform! If you have any questions, feel free to reach out to the maintainers.