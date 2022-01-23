###################################
## Virtual Machine Module - Main ##
###################################

# Bootstrapping Script for Radius VM
data "template_file" "radius-userdata" {
  template = "${file("./scripts/setup-server.tpl")}"

  vars = {
    MARIA_HOST = aws_db_instance.db-instance.address
    MARIA_USER = aws_db_instance.db-instance.username
    MARIA_PASS = var.db_password
    RADIUS_SEC = var.directory_password
  }
}

######################################

# Create the security group for Radius VM
resource "aws_security_group" "radius-sg" {
  name        = "${var.app_name}-${var.app_environment}-radius-sg"
  description = "Radius Security Group"
  vpc_id      = module.vpc.vpc_id
  
  # All Traffic
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Full internal access"
  }

  # Port 1812/1813 radius
  ingress {
    from_port   = 1812
    to_port     = 1813
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Radius Ports 1812/1813"
  }
  
  # Port 1645/1646 radius
  ingress {
    from_port   = 1645
    to_port     = 1646
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Radius Ports 1645/1646"
  }

    # Port 22 ssh from internal network
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Remote Access (SSH)"
  }

  # Egress traffic
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${lower(var.app_name)}-${var.app_environment}-radius-sg"
    Environment = var.app_environment
  }
}

######################################

# Get Latest Amazon Linux 2 AMI
data "aws_ami" "amazon-linux-2" {
  owners = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

# Create EC2 Instance for Radius VM
resource "aws_instance" "radius-server" {
  ami                         = data.aws_ami.amazon-linux-2.id
  instance_type               = var.radius_instance_size
  subnet_id                   = module.vpc.private_subnets[0]  # private
  associate_public_ip_address = var.radius_associate_public_ip_address
  vpc_security_group_ids      = [aws_security_group.radius-sg.id]
  source_dest_check           = false
  key_name                    = var.radius_key_pair
  user_data                   = data.template_file.radius-userdata.rendered
  
  # root disk
  root_block_device {
    volume_size           = var.radius_root_volume_size
    volume_type           = var.radius_root_volume_type
    delete_on_termination = true
  }

  tags = {
    Name = "${lower(var.app_name)}-${var.app_environment}-radius"
    Environment = var.app_environment
  }

  volume_tags = {
    Name = "${lower(var.app_name)}-${var.app_environment}-radius"
    Environment = var.app_environment
  }
}

# Create Security Rules to Allow Radius Traffic from Private Subnets in AD Security Group
resource "aws_security_group_rule" "radius-ad-ingress" {
  type              = "ingress"
  from_port         = 1812
  to_port           = 1813
  protocol          = "udp"
  description       = "Radius Ports 1812/1813"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_directory_service_directory.aws-managed-ad.security_group_id 

  depends_on = [
    aws_instance.radius-server
  ]
}

resource "aws_security_group_rule" "radius-ad-egress" {
  type              = "egress"
  from_port         = 1812
  to_port           = 1813
  protocol          = "udp"
  description       = "Radius Ports 1812/1813"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_directory_service_directory.aws-managed-ad.security_group_id 

  depends_on = [
    aws_instance.radius-server
  ]
}