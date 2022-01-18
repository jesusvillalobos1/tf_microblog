# Example TF configuration for dev environment
# It will deploy all infra on a dev stage

# Use terraform cloud as a backend  UNCOMMENT UNTIL PROOF OF CONCEPT IS DONE
terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "big-app"

    workspaces {
      name = "big-project"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

module "network" {
  source = "./network/"
}