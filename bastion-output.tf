#####################################
## Virtual Machine Module - Output ##
#####################################

output "bastion_instance_id" {
  value = aws_instance.bastion-server.id
}

output "bastion_instance_private_ip" {
  value = aws_instance.bastion-server.private_ip
}

output "bastion_instance_public_ip" {
  value = aws_eip.bastion-eip.public_ip
}
