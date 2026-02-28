terraform {
  # backend "local" {
  #   path = "state/dev-addons/terraform.tfstate"
  # }
  backend "gcs" {
    bucket  = "my-dev-770-tfstate-dev"
    prefix  = "terraform/dev-addons"
  }
}
