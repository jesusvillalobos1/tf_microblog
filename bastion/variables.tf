variable "aws_region" {
  description = "aws region to work on"
  default     = "us-west-2"
}

#This needs a data soruce to automatically retrieve the latest AMI
variable "bastion_ami" {
  description = "AMI ID to use for bastion"
  default     = "set the ami created on Packer here"
}

variable "instance_type" {
  description = "Instance type to use for bastion"
  default     = "t2.micro"
}