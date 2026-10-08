# Terraform Fundamentals — AWS Infrastructure as Code

A hands-on implementation of Terraform fundamentals on AWS, progressing from basic EC2 provisioning to variables, outputs, remote state, reusable modules, Terraform Registry modules, and Terraform/provider version management.

This project was completed as part of **Assignment 5 — Terraform Fundamentals** using a personal AWS environment and Terraform running locally on Ubuntu.

---

## Project Overview

The objective of this assignment was to understand how Terraform can be used to define, provision, modify, inspect, and destroy AWS infrastructure through **Infrastructure as Code (IaC)**.

The practical workflow followed throughout the project was:

```text
Write Configuration
       ↓
terraform init
       ↓
terraform validate
       ↓
terraform plan
       ↓
terraform apply
       ↓
Verify Infrastructure
       ↓
terraform destroy
```

The implementation progressed from a basic EC2 instance to reusable Terraform modules, Registry modules, and remote state management using Amazon S3.

---

## Technologies Used

- Terraform
- AWS
- AWS CLI
- Ubuntu Linux
- Git
- GitHub
- Amazon EC2
- Amazon VPC
- Amazon S3
- Terraform Registry
- Terraform Modules

### Environment

| Component | Configuration |
|---|---|
| AWS Region | `ap-south-1` (Mumbai) |
| Terraform | `v1.16.5` |
| AWS Provider | `~> 5.92` |
| EC2 Instance Type | `t3.micro` |
| OS / Environment | Ubuntu VM |

---

# Labs Completed

## Lab 3 — Build Infrastructure

### Objective

Understand the basic Terraform workflow by provisioning an AWS EC2 instance using Terraform.

### What We Did

Created a Terraform configuration containing:

- AWS provider
- Ubuntu AMI data source
- EC2 instance resource
- EC2 instance type
- Resource tags

The AMI was dynamically selected using an AWS AMI data source.

The EC2 instance was deployed in:

```text
Region:        ap-south-1
Instance Type: t3.micro
Name:          learn-terraform
```

### Workflow

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

The infrastructure was verified using Terraform state and the AWS Console.

After verification:

```bash
terraform destroy
```

### Key Learning

Terraform can describe AWS infrastructure declaratively and create it consistently from configuration files instead of manually provisioning resources through the AWS Console.

---

## Lab 4 — Manage Infrastructure

### Objective

Understand how Terraform manages infrastructure changes and introduce variables, outputs, and modules into the configuration.

### What We Did

Started with an EC2 configuration and introduced:

- Input variables
- Terraform outputs
- A reusable VPC module
- EC2 deployment inside the created VPC

The VPC configuration used:

```text
CIDR: 10.0.0.0/16

Availability Zones:
- ap-south-1a
- ap-south-1b
- ap-south-1c

Private Subnets:
- 10.0.1.0/24
- 10.0.2.0/24

Public Subnet:
- 10.0.101.0/24
```

We also inspected Terraform-managed resources using:

```bash
terraform state list
terraform state show
```

### Key Learning

Terraform maintains a state representation of infrastructure and uses that state to determine what needs to be created, changed, or destroyed.

---

## Lab 5 — Destroy Infrastructure

### Objective

Understand the difference between removing a resource from Terraform configuration and destroying the entire Terraform-managed infrastructure.

### What We Did

Created infrastructure consisting of:

- VPC
- Subnets
- Route tables
- Internet Gateway
- Security resources
- EC2 instance

We then removed the EC2 resource from the Terraform configuration.

Terraform detected that the resource existed in state but was no longer defined in the desired configuration.

Running:

```bash
terraform plan
```

showed that the removed EC2 resource would be destroyed.

After applying the configuration, only that resource was removed.

Finally:

```bash
terraform destroy
```

was used to destroy the remaining infrastructure.

### Key Learning

Terraform compares the desired configuration with its state to determine infrastructure changes. Removing a resource from the configuration can therefore cause Terraform to destroy that resource.

---

## Lab 6 — Define Input Variables

### Objective

Learn how to make Terraform configurations configurable and reusable using input variables.

### What We Did

Created variables for:

```text
instance_name
instance_type
```

Example:

```hcl
variable "instance_name" {
  description = "value of the EC2 instance's Name tag."
  type        = string
  default     = "input-terraform"
}

variable "instance_type" {
  description = "The EC2 instance's type."
  type        = string
  default     = "t3.micro"
}
```

The EC2 resource consumed these variables instead of hard-coded values.

We also used:

```bash
terraform console
```

to inspect a variable value.

### Key Learning

Input variables separate configuration values from infrastructure definitions, making Terraform configurations easier to customize and reuse.

---

## Lab 7 — Query Data with Outputs

### Objective

Understand Terraform outputs and expose useful information from deployed infrastructure.

### What We Did

Created outputs for:

- EC2 Instance ID
- Public IP Address
- Public DNS Name

Example:

```hcl
output "instance_id" {
  description = "ID of the EC2 instance."
  value       = aws_instance.app_server.id
}
```

After deployment, output values were retrieved using:

```bash
terraform output
```

Terraform state was also inspected using:

```bash
terraform state list
```

### Key Learning

Outputs provide a clean way to expose important information generated by infrastructure resources and make Terraform configurations easier to integrate with other workflows.

---

## Lab 8 — Store Remote State Using Amazon S3

### Objective

Understand how Terraform state can be stored remotely instead of keeping the state only on the local machine.

### What We Did

Created an Amazon S3 bucket specifically for Terraform state and enabled bucket versioning.

Terraform was configured with an S3 backend:

```hcl
terraform {
  backend "s3" {
    bucket = "srujan-terraform-state-<ACCOUNT_ID>"
    key    = "08-s3-remote-state/terraform.tfstate"
    region = "ap-south-1"
  }
}
```

The backend was initialized using:

```bash
terraform init
```

Before the first apply, Terraform reported that no state file was found because the remote state had not yet been written.

After deployment, the state was stored in S3 and verified using AWS CLI.

### Key Learning

Terraform state can be stored remotely using an S3 backend, providing persistent centralized state storage instead of relying only on a local state file.

---

## Lab 9 — Create a Terraform Module

### Objective

Understand how to create a reusable Terraform module instead of keeping infrastructure definitions directly in the root configuration.

### What We Did

Created the following structure:

```text
09-create-module/
├── main.tf
└── modules/
    └── ec2/
        ├── main.tf
        └── variables.tf
```

The module contained the EC2 resource:

```hcl
resource "aws_instance" "this" {
  ami           = var.ami
  instance_type = var.instance_type

  tags = {
    Name = var.name
  }
}
```

The module accepted:

```text
ami
instance_type
name
```

as input variables.

The root configuration called the module:

```hcl
module "ec2" {
  source = "./modules/ec2"

  ami           = "ami-065d2b03fb493085a"
  instance_type = "t3.micro"
  name          = "module-terraform"
}
```

Terraform state identified the resource through:

```text
module.ec2.aws_instance.this
```

### Key Learning

Terraform modules package infrastructure logic into reusable components. The root configuration can focus on using the module while the module contains the implementation details.

---

## Lab 10 — Use Modules from the Terraform Registry

### Objective

Learn how to consume an existing module from the Terraform Registry instead of building every infrastructure resource manually.

### What We Did

Used the VPC module:

```text
terraform-aws-modules/vpc/aws
```

with:

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"

  name = "registry-module-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24"]

  enable_dns_hostnames = true
}
```

Terraform downloaded the module during:

```bash
terraform init
```

The plan contained:

```text
15 resources to add
```

The module created the VPC and supporting networking resources, including:

- VPC
- Internet Gateway
- Public subnet
- Private subnets
- Route tables
- Route table associations
- Default security group
- Default network ACL
- Routing configuration

The infrastructure was successfully applied and later destroyed.

### Key Learning

Terraform Registry modules allow existing infrastructure patterns to be reused instead of recreating complex infrastructure configurations from scratch.

A single module block can represent many underlying AWS resources.

---

## Lab 11 — Manage Terraform Versions and Providers

### Objective

Understand how Terraform versions and provider versions can be controlled using version constraints.

### What We Did

Defined a Terraform version constraint:

```hcl
required_version = ">= 1.2, < 2.0"
```

and an AWS provider constraint:

```hcl
required_providers {
  aws = {
    source  = "hashicorp/aws"
    version = "~> 5.92"
  }
}
```

The configuration created a `t3.micro` EC2 instance.

The following workflow was used:

```bash
terraform init
terraform version
terraform validate
terraform plan
terraform apply
```

Terraform also generated:

```text
.terraform.lock.hcl
```

which records provider selection and checksums.

After verification, the EC2 instance was destroyed.

### Key Learning

Version constraints make Terraform projects more predictable by controlling which Terraform and provider versions are compatible with the configuration.

---

# State Management

Terraform state was intentionally kept out of Git.

The repository `.gitignore` contains:

```gitignore
.terraform/
*.tfstate
*.tfstate.*
```

This prevents local Terraform state and downloaded provider/module directories from being committed to GitHub.

For the remote-state lab, Terraform state was stored in Amazon S3.

---

# Infrastructure Cleanup

Each practical AWS lab followed a:

```text
Create → Verify → Destroy
```

workflow.

Resources were destroyed after testing using:

```bash
terraform destroy
```

This was done to avoid leaving unnecessary AWS resources running.

The S3 backend bucket created for the remote-state demonstration is separate from the EC2/VPC resources managed in the individual labs.

---

# Repository Structure

```text
terraform-assignment-5/
│
├── .gitignore
│
├── 03-create-infrastructure/
│   ├── main.tf
│   └── terraform.tf
│
├── 04-manage-infrastructure/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tf
│
├── 05-destroy-infrastructure/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tf
│
├── 06-input-variables/
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tf
│
├── 07-query-data-outputs/
│   ├── main.tf
│   ├── outputs.tf
│   └── terraform.tf
│
├── 08-s3-remote-state/
│   ├── main.tf
│   └── terraform.tf
│
├── 09-create-module/
│   ├── main.tf
│   └── modules/
│       └── ec2/
│           ├── main.tf
│           └── variables.tf
│
├── 10-registry-module/
│   └── main.tf
│
└── 11-terraform-versions-providers/
    ├── main.tf
    ├── terraform.tf
    └── .terraform.lock.hcl
```

---

# Terraform Workflow Used

```text
                 ┌──────────────────┐
                 │ Terraform Config │
                 │     (*.tf)       │
                 └────────┬─────────┘
                          │
                          ▼
                  terraform init
                          │
                          ▼
                 terraform validate
                          │
                          ▼
                   terraform plan
                          │
                          ▼
                  terraform apply
                          │
                          ▼
                 AWS Infrastructure
                          │
                          ▼
                  Verify / Inspect
                          │
                          ▼
                 terraform destroy
```

---

# Key Takeaways

| Area | What Was Learned |
|---|---|
| Infrastructure as Code | AWS infrastructure can be defined and managed through code |
| Terraform State | Terraform tracks managed infrastructure using state |
| Variables | Configuration values can be separated from infrastructure definitions |
| Outputs | Important infrastructure information can be exposed cleanly |
| Remote State | Terraform state can be stored remotely using Amazon S3 |
| Modules | Infrastructure logic can be packaged into reusable components |
| Registry Modules | Existing modules can be reused instead of rebuilding infrastructure |
| Version Constraints | Terraform and provider versions can be controlled |
| Lifecycle Management | Terraform can create, modify, inspect, and destroy infrastructure |

---

# Conclusion

This project provided a practical progression from provisioning a single AWS EC2 instance to managing structured AWS networking infrastructure through reusable modules, Registry modules, remote state, and version constraints.

The final implementation demonstrates the core Terraform lifecycle:

```text
Define → Initialize → Validate → Plan → Apply → Inspect → Destroy
```

The project also demonstrates an important Infrastructure as Code principle:

> **Infrastructure should be reproducible, version-controlled, reviewable, and managed through code rather than manual configuration.**
