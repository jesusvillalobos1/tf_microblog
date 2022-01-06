
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
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name        = "${var.project_name}-vpc"
    Environment = var.environment
  }
}

# Create Public Subnet1
resource "aws_subnet" "pub_sub1" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.pub_sub1_cidr
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true
  tags = {
    Name        = "${var.project_name}-pub_sub1"
    Environment = var.environment
  }
}

# Create Public Subnet2
resource "aws_subnet" "pub_sub2" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.pub_sub2_cidr
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = true
  tags = {
    Name        = "${var.project_name}-pub_sub2"
    Environment = var.environment
  }
}

# Create Private Subnet1
resource "aws_subnet" "prv_sub1" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.prv_sub1_cidr
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = false
  tags = {
    Name        = "${var.project_name}-prv_sub1"
    Environment = var.environment
  }
}

# Create Private Subnet2
resource "aws_subnet" "prv_sub2" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.prv_sub2_cidr
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = false
  tags = {
    Name        = "${var.project_name}-prv_sub2"
    Environment = var.environment
  }
}

#Create Database Private Subnet
resource "aws_subnet" "database-subnet-1" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = var.db_sub1_cidr
  availability_zone = "us-west-2a"
  tags = {
    Name        = "${var.project_name}-database-subnet-1"
    Environment = var.environment
  }
}

resource "aws_subnet" "database-subnet-2" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = var.db_sub2_cidr
  availability_zone = "us-west-2b"
  tags = {
    Name        = "${var.project_name}-database-subnet-2"
    Environment = var.environment
  }
}

resource "aws_db_subnet_group" "app-rds-sng" {
  name       = "app-rds-sng"
  subnet_ids = [aws_subnet.prv_sub1.id, aws_subnet.prv_sub2.id, aws_subnet.database-subnet-1.id, aws_subnet.database-subnet-2.id]

  tags = {
    Name        = "${var.project_name}-app-rds-sng"
    Environment = var.environment
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name        = "${var.project_name}-igw"
    Environment = var.environment
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
    Name        = "${var.project_name}-pub_sub1_rt"
    Environment = var.environment
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
  tags = {
    Name        = "${var.project_name}-eip_natgw1"
    Environment = var.environment
  }
}

# Create NAT gateway1
resource "aws_nat_gateway" "natgateway_1" {
  allocation_id = aws_eip.eip_natgw1.id
  subnet_id     = aws_subnet.pub_sub1.id
  tags = {
    Name        = "${var.project_name}-natgateway_1"
    Environment = var.environment
  }
}

# Create EIP for NAT GW2
resource "aws_eip" "eip_natgw2" {
  vpc = true
  tags = {
    Name        = "${var.project_name}-eip_natgw2"
    Environment = var.environment
  }
}

# Create NAT gateway2
resource "aws_nat_gateway" "natgateway_2" {
  allocation_id = aws_eip.eip_natgw2.id
  subnet_id     = aws_subnet.pub_sub2.id
  tags = {
    Name        = "${var.project_name}-natgateway_2"
    Environment = var.environment
  }
}

# Create private route table for prv sub1
resource "aws_route_table" "prv_sub1_rt" {
  vpc_id = aws_vpc.app_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgateway_1.id
  }
  tags = {
    Name        = "${var.project_name}-prv_sub1_rt"
    Environment = var.environment
  }
}

# Create route table association betn prv sub1 & NAT GW1
resource "aws_route_table_association" "pri_sub1_to_natgw1" {
  route_table_id = aws_route_table.prv_sub1_rt.id
  subnet_id      = aws_subnet.prv_sub1.id
}

# Create private route table for prv sub2
resource "aws_route_table" "prv_sub2_rt" {
  vpc_id = aws_vpc.app_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgateway_2.id
  }
  tags = {
    Name        = "${var.project_name}-prv_sub2_rt"
    Environment = var.environment
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
  vpc_id      = aws_vpc.app_vpc.id

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
    Name        = "${var.project_name}-elb_sg"
    Environment = var.environment
  }
}