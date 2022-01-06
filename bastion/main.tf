# Use terraform cloud as a backend UNCOMMENT UNTIL PROOF OF CONCEPT IS DONE
#terraform {
#  backend "remote" {
#    hostname = "app.terraform.io"
#    organization = "big-app"

#    workspaces {
#      name = "big-project"
#    }
#  }
#}


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

  vpc_id =  data.terraform_remote_state.network.outputs.app_vpc

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
  ami                         = var.bastion_ami
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.rafael_key.id
  subnet_id                   = data.terraform_remote_state.network.outputs.pub_sub1
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