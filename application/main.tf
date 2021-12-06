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

# Create security group for webserver
resource "aws_security_group" "webserver_sg" {
  name        = "web-server-security-group"
  description = "Allowing requests to the web servers"
  vpc_id = data.terraform_remote_state.network.outputs.app_vpc

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

resource "aws_key_pair" "rafael_app_key" {
  key_name   = "rafael_app_key"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMleeMMo9Nf2Po3tYf1nBFPvX+7DaUbqtEop0QEqDf2Z rafaelrojas@C02G95CEMD6R"
}

#Create Launch config
resource "aws_launch_configuration" "webserver-launch-config" {
  name_prefix   = "webserver-launch-config"
  #Image id should not be hardcoded
  image_id      = var.app_ami
  instance_type = var.app_instance_type
  key_name = aws_key_pair.rafael_app_key.id
  security_groups = [aws_security_group.webserver_sg.id]
  lifecycle {
    create_before_destroy = true
  }
  user_data = filebase64("../scripts/install-apache.sh")
}

# Create Auto Scaling Group
resource "aws_autoscaling_group" "app_web_asg" {
  name		     = "app-web-asg"
  desired_capacity   = var.app_desired_capacity
  max_size           = var.app_max_capacity
  min_size           = var.app_min_capacity
  force_delete       = true
  target_group_arns  =  [aws_lb_target_group.web-tg.arn]
  health_check_type  = "EC2"
  launch_configuration = aws_launch_configuration.webserver-launch-config.name
  vpc_zone_identifier = [data.terraform_remote_state.network.outputs.prv_sub1, data.terraform_remote_state.network.outputs.prv_sub2]
} 

# Create Target group
resource "aws_lb_target_group" "web-tg" {
  name     = "web-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.network.outputs.app_vpc
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
  security_groups    = [data.terraform_remote_state.network.outputs.elb_sg]
  subnets            = [data.terraform_remote_state.network.outputs.pub_sub1, data.terraform_remote_state.network.outputs.pub_sub2]
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