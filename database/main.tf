#####DB instance setup
resource "aws_security_group" "dbserver_sg" {
  name        = "dbserver_sg"
  description = "Allows connection for Database servers"
  vpc_id      = data.terraform_remote_state.network.outputs.app_vpc

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