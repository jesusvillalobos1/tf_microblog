#data "aws_availability_zones" "available" {
#  state = "available"
#}

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
resource "aws_default_subnet" "default_us-west-2a" {
  availability_zone = "us-west-2a"

  tags = {
    Name = "Default subnet for us-west-2a"
  }
}

resource "aws_db_instance" "appserver-db" {
  allocated_storage      = 20
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_type
  name                   = var.db_instance_name
  identifier             = var.db_identifier
  #this shouldn't be hardcoded like this
  username               = var.db_user
  password               = var.db_password
  db_subnet_group_name   = data.terraform_remote_state.network.outputs.app-rds-sng
  vpc_security_group_ids = [aws_security_group.dbserver_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
}