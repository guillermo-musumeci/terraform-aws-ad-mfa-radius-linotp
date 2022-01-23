###########################
## Network Module - Main ##
###########################

# AWS Availability Zones data
# data "aws_availability_zones" "available" {}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${lower(var.app_name)}-${var.app_environment}"
  cidr = var.vpc_cidr

  azs             = var.az_list
  private_subnets = var.private_subnets_cidr 
  public_subnets  = var.public_subnets_cidr 

  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${lower(var.app_name)}-${var.app_environment}"
    Environment = var.app_environment
  }
}