terraform {
  backend "s3" {
    bucket = "srujan-terraform-state-045510281119"
    key    = "08-s3-remote-state/terraform.tfstate"
    region = "ap-south-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
  }

  required_version = ">= 1.2"
}
