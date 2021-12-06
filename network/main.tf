
# Use terraform cloud as a backend  UNCOMMENT UNTIL PROOF OF CONCEPT IS DONE
#terraform {
#  backend "remote" {
#    hostname = "app.terraform.io"
#    organization = "big-app"

#    workspaces {
#      name = "big-project"
#    }
#  }
#}

# Create VPC
resource "aws_vpc" "app_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "APP VPC"
  }
}

# Create Public Subnet1
resource "aws_subnet" "pub_sub1" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.pub_sub1_cidr
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "pub-1a"
  }
}

# Create Public Subnet2
resource "aws_subnet" "pub_sub2" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.pub_sub2_cidr
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = true
  tags = {
    Name = "pub-2a"
  }
}

# Create Private Subnet1
resource "aws_subnet" "prv_sub1" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.prv_sub1_cidr
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = false
  tags = {
    Name = "app-1a"
  }
}

# Create Private Subnet2
resource "aws_subnet" "prv_sub2" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.prv_sub2_cidr
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = false

  tags = {
    Name = "Application-1b"
  }
}

#Create Database Private Subnet
resource "aws_subnet" "database-subnet-1" {
  vpc_id            = aws_vpc.app_vpc.id
<<<<<<< HEAD
  cidr_block        = var.db_sub1_cidr
=======
  cidr_block        = "10.0.5.0/24"
>>>>>>> main
  availability_zone = "us-east-2a"

  tags = {
    Name = "Database-1a"
  }
}

resource "aws_subnet" "database-subnet-2" {
  vpc_id            = aws_vpc.app_vpc.id
<<<<<<< HEAD
  cidr_block        = var.db_sub2_cidr
=======
  cidr_block        = "10.0.6.0/24"
>>>>>>> main
  availability_zone = "us-east-2b"

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
<<<<<<< HEAD
=======
  #count = "1"
>>>>>>> main
}

# Create NAT gateway1
resource "aws_nat_gateway" "natgateway_1" {
<<<<<<< HEAD
=======
  #count         = "1"
>>>>>>> main
  allocation_id = aws_eip.eip_natgw1.id
  subnet_id     = aws_subnet.pub_sub1.id
}

# Create EIP for NAT GW2
resource "aws_eip" "eip_natgw2" {
  vpc = true
  #count = "1"
}

# Create NAT gateway2
resource "aws_nat_gateway" "natgateway_2" {
  #count         = "1"
  allocation_id = aws_eip.eip_natgw2.id
  subnet_id     = aws_subnet.pub_sub2.id
}

# Create private route table for prv sub1
resource "aws_route_table" "prv_sub1_rt" {
  #count  = "1"
  vpc_id = aws_vpc.app_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgateway_1.id
  }
}

# Create route table association betn prv sub1 & NAT GW1
resource "aws_route_table_association" "pri_sub1_to_natgw1" {
<<<<<<< HEAD
=======
  #count          = "1"
>>>>>>> main
  route_table_id = aws_route_table.prv_sub1_rt.id
  subnet_id      = aws_subnet.prv_sub1.id
}

# Create private route table for prv sub2
resource "aws_route_table" "prv_sub2_rt" {
<<<<<<< HEAD
=======
  #count  = "1"
>>>>>>> main
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
<<<<<<< HEAD
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

=======
}
>>>>>>> main
