########################################
## Virtual Machine Module - Variables ##
########################################

variable "radius_instance_size"  {
  type        = string
  description = "EC2 instance type"
  default     = "t3a.medium"
}

variable "radius_key_pair" {
  type        = string
  description = "AWS Key Pair"
}

variable "radius_associate_public_ip_address" {
  type        = bool
  description = "Associate a public IP address to the EC2 instance"
  default     = false
}

variable "radius_root_volume_size" {
  type        = number
  description = "Volumen size of root volumen of EC2 Instance"
  default     = 60
}

variable "radius_root_volume_type" {
  type        = string
  description = "Volumen type of root volumen of ad Server. Can be standard, gp2, io1, sc1 or st1"
  default     = "gp2"
}

variable "radius_server_name" {
  type        = string
  description = "This variable defines the name of server"
}

 