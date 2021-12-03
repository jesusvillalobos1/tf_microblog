####This must change to a more secure env.

variable "TF_VAR_AWS_ACCESS_KEY_ID" {}
variable "TF_VAR_AWS_SECRET_ACCESS_KEY" {}
variable "TF_VAR_REGION" {}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
}



#provider "aws" {
#  profile    =  "terraform"
#  region     = "us-east-2"
#}
