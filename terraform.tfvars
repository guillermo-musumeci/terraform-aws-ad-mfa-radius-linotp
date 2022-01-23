# Application Definition 
app_name        = "kopicloud" # Do NOT enter any spaces
app_environment = "test" # Dev, Test, Staging, Prod, etc

# AWS Settings
aws_region        = "eu-west-1"
aws_access_key    = "complete-this"
aws_secret_key    = "complete-this"

# Network Configuration
az_list              = ["eu-west-1a", "eu-west-1b"]
vpc_cidr             = "10.10.0.0/16"
public_subnets_cidr  = ["10.10.1.0/24", "10.10.2.0/24"]
private_subnets_cidr = ["10.10.3.0/24", "10.10.4.0/24"]

# Bastion Server
bastion_instance_size    = "t3a.small"
bastion_key_pair         = "kopicloud-dev-ireland"
bastion_root_volume_size = 40
bastion_server_name      = "kopi-bastion"

# Radius Server
radius_instance_size    = "t3a.small"
radius_key_pair         = "kopicloud-dev-ireland"
radius_root_volume_size = 60
radius_server_name      = "kopi-radius1"

# AWS Managed AD
directory_name     = "kopicloud.local"
directory_password = "Sw33tCh0c0l@t3"
directory_edition  = "Standard"
  
# MariaDB Database
db_user     = "kopirootadmin"
db_password = "H0tGr33nP3pp3r"
