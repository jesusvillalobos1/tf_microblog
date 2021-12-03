####This must change to a more secure env.
provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
}
#provider "aws" {
#  profile    =  "terraform"
#  region     = "us-east-2"
}
