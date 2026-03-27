# Terraform configuration block
# This defines the minimum Terraform version and required providers
terraform {
  backend "s3" {
    bucket = "2026-03-backend"
    key    = "tfbuild2/terraform.tfstate"
    region = "us-east-1"
  }

  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# AWS Provider configuration
# This tells Terraform how to connect to AWS
provider "aws" {
  region  = "us-east-1"
  profile = "default"
}
