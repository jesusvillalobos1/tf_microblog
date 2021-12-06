variable "aws_region" {
  description = "aws region to work on"
  default     = "us-east-2"
}

#This needs a data soruce to automatically retrieve the latest AMI
variable "bastion_ami" {
  description = "AMI ID to use for bastion"
  default     = "ami-074cce78125f09d61"
}

variable "instance_type" {
  description = "Instance type to use for bastion"
  default     = "t2.micro"
}