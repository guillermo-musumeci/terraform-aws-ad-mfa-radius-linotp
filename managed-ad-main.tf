###################################
## AWS AD Managed Service - Main ##
###################################

resource "aws_directory_service_directory" "aws-managed-ad" {
  name        = var.directory_name
  description = var.directory_description
  password    = var.directory_password
  edition     = var.directory_edition
  type        = "MicrosoftAD"

  vpc_settings {
    vpc_id     = module.vpc.vpc_id
    subnet_ids = module.vpc.private_subnets
  }

  tags = {
    Name = "${lower(var.app_name)}-${var.app_environment}-managed-ad"
    Environment = var.app_environment
  }
}
