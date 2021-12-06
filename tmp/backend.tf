terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "Java-App"

    workspaces {
      name = "big-project"
    }
  }
}