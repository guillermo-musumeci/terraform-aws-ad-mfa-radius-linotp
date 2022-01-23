resource "aws_vpc_dhcp_options" "dns_resolver" {
  domain_name_servers = aws_directory_service_directory.aws-managed-ad.dns_ip_addresses
  domain_name         = var.directory_name

  tags = {
    Name = "${lower(var.app_name)}-${var.app_environment}-dhcp-option"
    Environment = var.app_environment
  }
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = module.vpc.vpc_id
  dhcp_options_id = aws_vpc_dhcp_options.dns_resolver.id
}