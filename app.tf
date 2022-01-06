# Create VPC
resource "aws_vpc" "app_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "APP VPC"
  }
}

# Create Public Subnet1
resource "aws_subnet" "pub_sub1" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "pub-1a"
  }
}

# Create Public Subnet2
resource "aws_subnet" "pub_sub2" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = "10.0.7.0/24"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = true
  tags = {
    Name = "pub-2a"
  }
}

# Create Private Subnet1
resource "aws_subnet" "prv_sub1" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = false

  tags = {
    Name = "Application-1a"
  }
}

# Create Private Subnet2
resource "aws_subnet" "prv_sub2" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = false

  tags = {
    Name = "Application-1b"
  }
}

#Create Database Private Subnet
resource "aws_subnet" "database-subnet-1" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "Database-1a"
  }
}

resource "aws_subnet" "database-subnet-2" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "Database-2b"
  }
}

resource "aws_db_subnet_group" "app-rds-sng" {
  name       = "app-rds-sng"
  subnet_ids = [aws_subnet.prv_sub1.id, aws_subnet.prv_sub2.id, aws_subnet.database-subnet-1.id, aws_subnet.database-subnet-2.id]

  tags = {
    Name = "app-rds-sng"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "Demo IGW"
  }
}

# Create Public Route Table
resource "aws_route_table" "pub_sub1_rt" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "WebRT"
  }
}

# Create route table association of public subnet1
resource "aws_route_table_association" "internet_for_pub_sub1" {
  route_table_id = aws_route_table.pub_sub1_rt.id
  subnet_id      = aws_subnet.pub_sub1.id
}
# Create route table association of public subnet2

resource "aws_route_table_association" "internet_for_pub_sub2" {
  route_table_id = aws_route_table.pub_sub1_rt.id
  subnet_id      = aws_subnet.pub_sub2.id
}

# Create EIP for NAT GW1
  resource "aws_eip" "eip_natgw1" {
  vpc = true    
}

# Create NAT gateway1
resource "aws_nat_gateway" "natgateway_1" {
  allocation_id = aws_eip.eip_natgw1.id
  subnet_id     = aws_subnet.pub_sub1.id
}

# Create EIP for NAT GW2
resource "aws_eip" "eip_natgw2" {
  vpc = true
}

# Create NAT gateway2
resource "aws_nat_gateway" "natgateway_2" {
  allocation_id = aws_eip.eip_natgw2.id
  subnet_id     = aws_subnet.pub_sub2.id
}

# Create private route table for prv sub1
resource "aws_route_table" "prv_sub1_rt" {
  vpc_id = aws_vpc.app_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgateway_1.id
  }
}

# Create route table association betn prv sub1 & NAT GW1
resource "aws_route_table_association" "pri_sub1_to_natgw1" {
  #count          = "1"
  route_table_id = aws_route_table.prv_sub1_rt.id
  subnet_id      = aws_subnet.prv_sub1.id
}

# Create private route table for prv sub2
resource "aws_route_table" "prv_sub2_rt" {
  vpc_id =  aws_vpc.app_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgateway_2.id
  }
}

# Create route table association betn prv sub2 & NAT GW2
resource "aws_route_table_association" "pri_sub2_to_natgw1" {
  count          = "1"
  route_table_id = aws_route_table.prv_sub2_rt.id
  subnet_id      = aws_subnet.prv_sub2.id
}

# Create security group for load balancer
resource "aws_security_group" "elb_sg" {
  name        = "alb-security-group"
  description = "Allowing HTTP requests to the application load balancer"
  vpc_id = aws_vpc.app_vpc.id

ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "HTTP"
    cidr_blocks = ["0.0.0.0/0"]
  }

egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
 
  tags = {
    Name = "alb-security-group"
  }
}

# Create security group for webserver
resource "aws_security_group" "webserver_sg" {
  name        = "web-server-security-group"
  description = "Allowing requests to the web servers"
  vpc_id = aws_vpc.app_vpc.id

ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "HTTP"
    cidr_blocks = ["0.0.0.0/0"]

 }

ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "HTTP"
    cidr_blocks = ["0.0.0.0/0"]
  }
egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

tags = {
    Name = "web-server-security-group"
  }
}

###This key must be encrypted
resource "aws_key_pair" "rafael_key" {
  key_name   = "rafael_key"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMleeMMo9Nf2Po3tYf1nBFPvX+7DaUbqtEop0QEqDf2Z rafaelrojas@C02G95CEMD6R"
}

#Create Launch config
resource "aws_launch_configuration" "webserver-launch-config" {
  name_prefix   = "webserver-launch-config"
  #Image id should not be hardcoded
  image_id      = "ami-074cce78125f09d61"
  instance_type = "t2.micro"
  key_name = aws_key_pair.rafael_key.id
  security_groups = [aws_security_group.webserver_sg.id]
  lifecycle {
    create_before_destroy = true
  }
  user_data = filebase64("scripts/install-apache.sh")
}

# Create Auto Scaling Group
resource "aws_autoscaling_group" "web_asg" {
  name		     = "Demo-ASG-tf"
  desired_capacity   = 2
  max_size           = 3
  min_size           = 1
  force_delete       = true
  target_group_arns  =  [aws_lb_target_group.web-tg.arn]
  health_check_type  = "EC2"
  launch_configuration = aws_launch_configuration.webserver-launch-config.name
  vpc_zone_identifier = [aws_subnet.prv_sub1.id, aws_subnet.prv_sub2.id]
} 

# Create Target group
resource "aws_lb_target_group" "web-tg" {
  name     = "web-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.app_vpc.id
  health_check {
    port                = 80
    protocol            = "HTTP"
  }
}

# Create ALB
resource "aws_lb" "app_lb" {
   name              = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.elb_sg.id]
  subnets            = [aws_subnet.pub_sub1.id,aws_subnet.pub_sub2.id]
}

# Create ALB Listener 
resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-tg.arn
  }
}

# Define the security group for the Bastion
resource "aws_security_group" "app-bastion-sg" {
  name        = "app-bastion-sg"
  description = "Access to Bastion Server"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id =  aws_vpc.app_vpc.id

  tags = {
    Name        = "app-bastion-sg"
  }
}

# Create Bastion Elastic IP
resource "aws_eip" "app-bastion-eip" {
  vpc = true
  tags = {
    Name        = "app-bastion-eip"
  }
}

# Create EC2 Instance for Bastion Server
resource "aws_instance" "app-bastion-host" {
  ami                         = "ami-074cce78125f09d61"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.rafael_key.id
  subnet_id                   = aws_subnet.pub_sub1.id
  vpc_security_group_ids      = [ aws_security_group.app-bastion-sg.id]
  associate_public_ip_address = true
  source_dest_check           = false
  tags = {
    Name        = "app-bastion"
  }
}

# Associate Test Bastion Elastic IP
resource "aws_eip_association" "app-bastion-eip-association" {
  instance_id   = aws_instance.app-bastion-host.id
  allocation_id = aws_eip.app-bastion-eip.id
}

#####DB instance setup
resource "aws_security_group" "dbserver_sg" {
  name        = "dbserver_sg"
  description = "Allows connection for Database servers"
  vpc_id      = aws_vpc.app_vpc.id

  #MYSQL
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #ALL
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#This shouldn't be hardcoded
resource "aws_default_subnet" "default_us-west-2a" {
  availability_zone = "us-west-2a"

  tags = {
    Name = "Default subnet for us-west-2a"
  }
}

resource "aws_db_instance" "appserver-db" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0.23"
  instance_class         = "db.t2.micro"
  name                   = "appmaindb"
  identifier             = "app-database"
  #this shouldn't be hardcoded like this
  username               = "dbadmin"
  password               = "xTkjwje6UM3v"
  db_subnet_group_name   = aws_db_subnet_group.app-rds-sng.id
  vpc_security_group_ids = [aws_security_group.dbserver_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
}

resource "aws_db_instance" "appserver-db-test1" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0.23"
  instance_class         = "db.t2.micro"
  name                   = "appmaindb"
  identifier             = "app-database"
  #this shouldn't be hardcoded like this
  username               = "dbadmin"
  password               = "xTkjwje6UM3v"
  db_subnet_group_name   = aws_db_subnet_group.app-rds-sng.id
  vpc_security_group_ids = [aws_security_group.dbserver_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
}