############################
## Database Module - Main ##
############################

# Create DB subnet group 
resource "aws_db_subnet_group" "db-subnet" {
  name        = "${var.app_name}-${var.app_environment}-db-subnet"
  description = "DB Subnet for ${var.app_name}"
  subnet_ids  = [ module.vpc.private_subnets[0], module.vpc.private_subnets[1]]

  tags = {
    Name        = "${var.app_name}-${var.app_environment}-db-instance"
    Environment = var.app_environment
  }
}

######################################

# Create Security Group for Database
resource "aws_security_group" "db-instance-sg" {
  name        = "${var.app_name}-${var.app_environment}-db-instance-sg"
  description = "Security group for RDS DB Instance"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }
  
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.app_name}-${var.app_environment}-db-instance"
    Environment = var.app_environment
  }
}

######################################

# Create the database instance
resource "aws_db_instance" "db-instance" {
  name              = "radiusotp"
  identifier        = "${var.app_name}-instance-db"
  password          = var.db_password
  username          = var.db_user

  instance_class    = "db.t2.micro"
  allocated_storage = 20
  engine            = "mariadb"
  engine_version    = "10.5.13"
    
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.db-subnet.name
  vpc_security_group_ids = [aws_security_group.db-instance-sg.id]

  tags = {
    Name        = "${var.app_name}-${var.app_environment}-db-instance"
    Environment = var.app_environment
  }
}
