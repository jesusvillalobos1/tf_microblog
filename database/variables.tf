variable "aws_region" {
  description = "aws region to work on"
  default     = "us-east-2"
}

variable "db_engine" {
  description = "DB Engine type"
  default     = "mysql"
}

variable "db_engine_version" {
  description = "DB Engine version"
  default     = "8.0.23"
}

#This needs a data soruce to automatically retrieve the latest AMI
variable "db_ami" {
  description = "AMI ID to use for app server"
  default     = "ami-074cce78125f09d61"
}

variable "db_instance_type" {
  description = "Instance type to use for app server"
  default     = "db.t2.micro"
}

variable "db_instance_name" {
  description = "Name of the DB instance"
  default = "appmaindb"
}

variable "db_identifier"{
    description = "DB instance identifier"
    default = "app-database"
}

##This must be protected
variable "db_user"{
    description = "DB user"
    default = "dbadmin"
}

variable "db_password"{
    description = "DB user password"
    default = "xTkjwje6UM3v"
}