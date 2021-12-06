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