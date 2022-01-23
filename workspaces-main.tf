#####################################
## Amazon WorkSpaces Module - Main ##
#####################################

# Create an Amazon WorkSpaces Directory
resource "aws_workspaces_directory" "workspaces-directory" {
  directory_id = aws_directory_service_directory.aws-managed-ad.id
  subnet_ids   = module.vpc.private_subnets

  depends_on = [aws_iam_role.workspaces-default]
}

# Create Amazon WorkSpaces Standard Bundles 
# 2 vCPU, 4GiB Memory, and 50GB Storage in English

# Windows Standard Bundle powered by Windows Server 2019
data "aws_workspaces_bundle" "standard_windows" {
  bundle_id = "wsb-gk1wpk43z"
}

# Linux Standard Bundle powered by Amazon Linux 2
data "aws_workspaces_bundle" "standard_linux" {
  bundle_id = "wsb-clj85qzj1"
}

# Create an Amazon WorkSpaces
resource "aws_workspaces_workspace" "workspaces" {
  directory_id = aws_workspaces_directory.workspaces-directory.id
  bundle_id    = data.aws_workspaces_bundle.standard_windows.id

  # Admin is the Administrator of the AWS Directory Service
  user_name = "Admin"

  root_volume_encryption_enabled = true
  user_volume_encryption_enabled = true
  volume_encryption_key          = aws_kms_key.workspaces-kms.arn

  workspace_properties {
    compute_type_name                         = "STANDARD"
    user_volume_size_gib                      = 50
    root_volume_size_gib                      = 80
    running_mode                              = "AUTO_STOP"
    running_mode_auto_stop_timeout_in_minutes = 60
  }

  tags = {
    Name = "${lower(var.app_name)}-${var.app_environment}-workspaces"
    Environment = var.app_environment
  }

  depends_on = [
    aws_iam_role.workspaces-default,
    aws_workspaces_directory.workspaces-directory
  ]
}