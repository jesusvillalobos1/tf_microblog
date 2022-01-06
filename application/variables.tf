variable "aws_region" {
  description = "aws region to work on"
  default     = "us-west-2"
}

#This needs a data soruce to automatically retrieve the latest AMI
variable "app_ami" {
  description = "AMI ID to use for app server"
  default     = "ami-074cce78125f09d61"
}

variable "app_instance_type" {
  description = "Instance type to use for app server"
  default     = "t2.micro"
}

variable "app_desired_capacity" {
    description = "desired capacity for app"
    default = "2"
}

variable "app_min_capacity" {
    description = "minimal capacity capacity for app"
    default = "1"
}

variable "app_max_capacity" {
    description = "maximum capacity for app"
    default = "3"
}