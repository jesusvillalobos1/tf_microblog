# Create a VPC
resource "aws_vpc" "app_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "APP VPC"
  }
}

# Create Web Public Subnet
resource "aws_subnet" "web-subnet-1" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Web-1a"
  }
}

resource "aws_subnet" "web-subnet-2" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Web-2b"
  }
}

# Create Application Private Subnet
resource "aws_subnet" "application-subnet-1" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = "10.0.11.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = false

  tags = {
    Name = "Application-1a"
  }
}

resource "aws_subnet" "application-subnet-2" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = "10.0.12.0/24"
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = false

  tags = {
    Name = "Application-2b"
  }
}

#Create Database Private Subnet
resource "aws_subnet" "database-subnet-1" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.0.21.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name = "Database-1a"
  }
}

resource "aws_subnet" "database-subnet-2" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.0.22.0/24"
  availability_zone = "us-east-2b"

  tags = {
    Name = "Database-2b"
  }
}

resource "aws_db_subnet_group" "app-rds-sng" {
  name       = "app-rds-sng"
  subnet_ids = [aws_subnet.application-subnet-1.id, aws_subnet.application-subnet-2.id, aws_subnet.database-subnet-1.id]

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
 
# Create Web layer route table
resource "aws_route_table" "web-rt" {
  vpc_id = aws_vpc.app_vpc.id
 
 
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
 
  tags = {
    Name = "WebRT"
  }
}
 
# Create Web Subnet association with Web route table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.web-subnet-1.id
  route_table_id = aws_route_table.web-rt.id
}
 
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.web-subnet-2.id
  route_table_id = aws_route_table.web-rt.id
}



# Create Web Subnet association with Web route table
resource "aws_route_table_association" "web_net_assoc1" {
  subnet_id      = aws_subnet.web-subnet-1.id
  route_table_id = aws_route_table.web-rt.id
}
 
resource "aws_route_table_association" "web_net_assoc2" {
  subnet_id      = aws_subnet.web-subnet-2.id
  route_table_id = aws_route_table.web-rt.id
}

# Web - Application Load Balancer
resource "aws_lb" "app_lb" {
  name = "app-lb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb_http.id]
  subnets = [aws_subnet.web-subnet-1.id, aws_subnet.web-subnet-2.id]
}

# Web - ALB Security Group
resource "aws_security_group" "alb_http" {
  name        = "alb-security-group"
  description = "Allowing HTTP requests to the application load balancer"
  vpc_id = aws_vpc.app_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-security-group"
  }
}


# Web - Listener
resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_target_group.arn
  }
}

# Web - Target Group
resource "aws_lb_target_group" "web_target_group" {
  name     = "web-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.app_vpc.id

  health_check {
    port     = 80
    protocol = "HTTP"
  }
}


# Web - EC2 Instance Security Group
resource "aws_security_group" "web_instance_sg" {
  name        = "web-server-security-group"
  description = "Allowing requests to the web servers"
  vpc_id = aws_vpc.app_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_http.id]
  }

  #For ssh into the instance
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-server-security-group"
  }
}

###This key must be encrypted
resource "aws_key_pair" "jesus_key" {
  key_name   = "jesus_key"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEb5x7YXs73HpA5Keyo1E/qRbzL98jR8knONXmh8yEdv Rafael Rojas big-berthassh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxMrES7uGK1edBIVtF+ODt3/g25ZFXlnV6TcVAUXgVQU9a47PgX0bZZlW9nUGiXwgiJa7OnJkicjCBd6o52R/nDsJK0gH7NJQAcTSlNAy7H0Lk48TC/D1HfRuADvo4Ys2uvcjmU/HdcsZf6LO/3Zg0QXkfv2Uc0lwjCfdr1idkRD5LBnYVPGAwSxmohqEbkIef5y+EFRziqAObEwqzWbaA9GBXj9ouUXiJbdy/0p7nPYf5UGk4yEjcT5EwiuYhfDzyElzCLmt5wvgLKSll/BhWVaw971w41y7ytQa9vSXOIM4HjaEm9jUc8+Z8ERIh6ObKMzXeHcI0n0GwwWe047t7 jarvis@Jarvis"
}

resource "aws_launch_template" "web_launch_template" {
  name_prefix   = "web-launch-template-"
  #Image id should not be hardcoded
  image_id      = "ami-074cce78125f09d61"
  instance_type = "t2.micro"
  key_name = aws_key_pair.jesus_key.id
  vpc_security_group_ids = [ aws_security_group.alb_http.id, aws_security_group.web_instance_sg.id]
  network_interfaces {
    associate_public_ip_address = false
  }
  user_data = filebase64("scripts/install-apache.sh")
}

# Web - Auto Scaling Group
resource "aws_autoscaling_group" "web_asg" {
  name               = "web_asg"
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1
  target_group_arns = [aws_lb_target_group.web_target_group.arn]
  vpc_zone_identifier = [aws_subnet.web-subnet-1.id, aws_subnet.web-subnet-1.id]

  launch_template {
    id      = aws_launch_template.web_launch_template.id
    version = "$Latest"
  }
}

# Create Bastion Elastic IP
resource "aws_eip" "app-bastion-eip" {
  vpc = true
  tags = {
    Name        = "app-bastion-eip"
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



# Create EC2 Instance for Windows Bastion Server
resource "aws_instance" "app-bastion-host" {
  ami                         = "ami-074cce78125f09d61"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.jesus_key.id
  subnet_id                   = aws_subnet.web-subnet-1.id
  vpc_security_group_ids      = [ aws_security_group.app-bastion-sg.id, aws_security_group.web_instance_sg.id ]
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

  #SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
resource "aws_default_subnet" "default_us-east-2a" {
  availability_zone = "us-east-2a"

  tags = {
    Name = "Default subnet for us-east-2a"
  }
}

resource "aws_db_instance" "appserver-db" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.023"
  instance_class         = "db.t2.micro"
  name                   = "app-main-db"
  identifier             = "app-database"
  #this shouldn't be hardcoded like this
  username               = "dbadmin"
  password               = "xTkjwje6UM3v"
  db_subnet_group_name   = "aws_db_subnet_group.app-rds-sng.id"
  vpc_security_group_ids = [aws_security_group.dbserver_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
}