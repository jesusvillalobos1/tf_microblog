#UNCOMMENT THIS UNTIL PROOF OF CONCEPTO IS DONE
# IN THE MEANTIME USE LOCAL STATES
#data "terraform_remote_state" "big-app" {
#  backend = "remote"

#  config = {
#    organization = "Java-app"

#    workspaces = {
#      name = "big-project"
#    }
#  }
#}

# Local remote state config
data "terraform_remote_state" "network" {
  backend = "local"

  config = {
    path = "../network/terraform.tfstate"
  }
}

data "aws_ami" "latest-bastion" {
  most_recent      = true
  owners           = ["385794018617"]

  filter {
    name   = "name"
    values = ["bastion-image*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}