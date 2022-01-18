# Example TF configuration for dev environment
# It will deploy all infra on a dev stage

provider "aws" {
  region = "us-east-2"
}

module "network" {
  source = "./network/"
}