########################################
## AWS AD Managed Service - Variables ##
########################################

variable "directory_name"  {
  type        = string
  description = "AWS AD Directory Service Name"
}

variable "directory_description"  {
  type        = string
  description = "AWS AD Directory Service Description"
  default     = ""
}

variable "directory_password"  {
  type        = string
  description = "AWS AD Directory Service Password"
}

variable "directory_edition"  {
  type        = string
  description = "AWS AD Directory Service Edition (Standard or Enterprise)"
  default     = "Standard"
}
