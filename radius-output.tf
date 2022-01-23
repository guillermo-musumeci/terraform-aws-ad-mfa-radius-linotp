#####################################
## Virtual Machine Module - Output ##
#####################################

output "radius_instance_id" {
  value = aws_instance.radius-server.id
}

output "radius_instance_private_ip" {
  value = aws_instance.radius-server.private_ip
}
