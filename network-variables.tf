################################
## Network Module - Variables ##
################################

variable "az_list" {
  type        = list(string)
  description = "List of AWS availability zones"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC IPv4 CIDR"
}

variable "public_subnets_cidr" {
  type        = list(string)
  description = "List of IPv4 CIDR for public subnets"
  default     = []
}

variable "private_subnets_cidr" {
  type        = list(string)
  description = "List of IPv4 CIDR for private subnets"
  default     = []
}

variable "database_subnets_cidr" {
  type        = list(string)
  description = "List of IPv4 CIDR for database subnets"
  default     = []
}

