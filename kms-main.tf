# Deploy a KMS to Encrypt Disk Volumes
resource "aws_kms_key" "workspaces-kms" {
  description             = "KopiCloud KMS"
  deletion_window_in_days = 7
}