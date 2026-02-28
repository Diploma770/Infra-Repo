terraform {
  # backend "local" {
  #   path = "state/dev/terraform.tfstate"
  # }

  backend "gcs" {
    bucket = "my-dev-770-tfstate-dev"
    prefix = "terraform/dev"
  }
}