###################################
## Virtual Machine Module - Main ##
###################################

# Bootstrapping PowerShell Script for Bastion VM
data "template_file" "bastion-userdata" {
  template = <<EOF
<powershell>
# Install Google Chrome
$Installer = $env:TEMP + "\chrome_installer.exe"; 
Invoke-WebRequest "http://dl.google.com/chrome/install/375.126/chrome_installer.exe" -OutFile $Installer; 
Start-Process -FilePath $Installer -Args "/silent /install" -Verb RunAs -Wait; 

# Rename Machine
Rename-Computer -NewName "${var.bastion_server_name}" -Force;

# Restart machine
shutdown -r -t 10;
</powershell>
EOF
}

######################################

# Create Bastion Elastic IP
resource "aws_eip" "bastion-eip" {
  vpc = true
  tags = {
    Name = "${var.app_name}-${var.app_environment}-bastion-ip"
    Environment = var.app_environment
  }
}

######################################

# Create the security group for Bastion VM
resource "aws_security_group" "bastion-sg" {
  name        = "${var.app_name}-${var.app_environment}-bastion-sg"
  description = "Bastion Security Group"
  vpc_id      = module.vpc.vpc_id
  
  # Port 3389 rdp
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Remote Desktop Access (RDP)"
  }

  # Egress traffic
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${lower(var.app_name)}-${var.app_environment}-bastion-sg"
    Environment = var.app_environment
  }
}

######################################

# Create EC2 Instance for Bastion VM
resource "aws_instance" "bastion-server" {
  ami                         = data.aws_ami.windows-2019.id
  instance_type               = var.bastion_instance_size
  subnet_id                   = module.vpc.public_subnets[0]  # public
  associate_public_ip_address = var.bastion_associate_public_ip_address
  vpc_security_group_ids      = [aws_security_group.bastion-sg.id]
  source_dest_check           = false
  key_name                    = var.bastion_key_pair
  user_data                   = data.template_file.bastion-userdata.rendered
  
  # root disk
  root_block_device {
    volume_size           = var.bastion_root_volume_size
    volume_type           = var.bastion_root_volume_type
    delete_on_termination = true
  }

  tags = {
    Name = "${lower(var.app_name)}-${var.app_environment}-bastion"
    Environment = var.app_environment
  }

  volume_tags = {
    Name = "${lower(var.app_name)}-${var.app_environment}-bastion"
    Environment = var.app_environment
  }
}

######################################

# Associate Bastion Elastic IP
resource "aws_eip_association" "bastion-eip-association" {
  instance_id   = aws_instance.bastion-server.id
  allocation_id = aws_eip.bastion-eip.id
}