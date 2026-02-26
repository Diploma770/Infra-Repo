terraform {
  # backend "local" {
  #   path = "state/dev-addons/terraform.tfstate"
  # }
  backend "gcs" {}
}
