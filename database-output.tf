##############################
## Database Module - Output ##
##############################

# output "database_subnet" {
#   value = aws_db_subnet_group.db-subnet
# }

# output "database_instance" {
#   value = aws_db_instance.db-instance
# }

# output "database_security_group" {
#   value = aws_security_group.db-instance-sg
# }


output "rds_hostname" {
  value = aws_db_instance.db-instance.address
}

output "rds_username" {
  value = aws_db_instance.db-instance.username
}

output "rds_password" {
  value = var.db_password
}