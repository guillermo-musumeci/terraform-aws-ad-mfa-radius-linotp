################################
## AWS Provider Module - Main ##
################################

# AWS Provider
provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
}

# Backend State File
terraform {
  required_version = ">= 0.13"
}

