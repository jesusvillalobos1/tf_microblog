variable "aws_region" {
  description = "aws region to work on"
  default     = "us-east-2"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  default     = "10.0.0.0/16"
}

variable "pub_sub1_cidr" {
  description = "CIDR for pub_sub1"
  default     = "10.0.1.0/24"
}

variable "pub_sub2_cidr" {
  description = "CIDR for pub_sub2"
  default     = "10.0.2.0/24"
}

variable "prv_sub1_cidr" {
  description = "CIDR for prv_sub1"
  default     = "10.0.3.0/24"
}

variable "prv_sub2_cidr" {
  description = "CIDR for prv_sub2"
  default     = "10.0.4.0/24"
}

variable "db_sub1_cidr" {
  description = "CIDR for database-subnet-1"
  default     = "10.0.5.0/24"
}

variable "db_sub2_cidr" {
  description = "CIDR for database-subnet-2"
  default     = "10.0.6.0/24"
}