module "argocd" {
  source = "../modules/argocd"

  create_repo_secret   = var.argocd_create_repo_secret
  repo_secret_name     = var.argocd_repo_secret_name
  repo_url             = var.argocd_repo_url
  repo_auth_type       = var.argocd_repo_auth_type
  repo_ssh_private_key = var.argocd_repo_ssh_private_key
  repo_username        = var.argocd_repo_username
  repo_password        = var.argocd_repo_password

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }
}

module "k8s_workload_setup" {
  source = "../modules/k8s-workload-setup"

  project_id        = var.project_id
  cloudsql_sa_email = var.cloudsql_sa_email

  namespaces        = var.workload_namespaces
  cloudsql_ksa_name = var.cloudsql_ksa_name

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }
}

module "eso" {
  source     = "../modules/eso"
  project_id = var.project_id

  namespace                   = var.eso_namespace
  k8s_service_account_name    = var.eso_k8s_service_account_name
  create_k8s_service_account  = var.eso_create_k8s_service_account
  gcp_service_account_id      = var.eso_gcp_service_account_id

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }
}
