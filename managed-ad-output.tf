#####################################
## AWS AD Managed Service - Output ##
#####################################

output "managed_ad_id" {
  value = aws_directory_service_directory.aws-managed-ad.id
}

output "managed_ad_url" {
  value = aws_directory_service_directory.aws-managed-ad.access_url
}

output "managed_ad_dns_ip_addresses" {
  value = aws_directory_service_directory.aws-managed-ad.dns_ip_addresses
}

output "managed_ad_security_group" {
  value = aws_directory_service_directory.aws-managed-ad.security_group_id 
}

