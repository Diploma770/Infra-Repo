# Project already exists (my-dev-770), no need to create
# module "project" {
#   source = "../modules/project"
#
#   name               = "my-dev"
#   project_id          = var.project_id
#   billing_account_id  = var.billing_account_id
#   org_id              = var.org_id
#
#   apis = [
#     "serviceusage.googleapis.com",
#     "compute.googleapis.com",
#     "iam.googleapis.com",
#     "container.googleapis.com",
#     "monitoring.googleapis.com",
#     "logging.googleapis.com",
#     "cloudtrace.googleapis.com",
#     "artifactregistry.googleapis.com",
#     "sqladmin.googleapis.com",
#     "pubsub.googleapis.com"
#   ]
# }

# Enable required APIs on existing project
resource "google_project_service" "required_apis" {
  for_each = toset([
    "serviceusage.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "container.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "cloudtrace.googleapis.com",
    "artifactregistry.googleapis.com",
    "sqladmin.googleapis.com",
    "pubsub.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudbuild.googleapis.com",
    "secretmanager.googleapis.com"
  ])

  project = var.project_id
  service = each.key

  disable_on_destroy = false
}

module "vpc" {
  source = "../modules/vpc"

  network_name = "${var.environment}-vpc"
  subnet_name  = "${var.environment}-subnet-1"
  region       = var.region
  subnet_cidr  = "10.10.0.0/20"

  enable_nat     = true
  reserve_nat_ip = false

  ssh_source_ranges = []

  gke_master_ipv4_cidr = "172.16.0.0/28"

  depends_on = [google_project_service.required_apis]
}

module "iam" {
  source                     = "../modules/iam"
  project_id                 = var.project_id
  terraform_github_principal = var.terraform_github_principal
  cicd_github_principal      = var.cicd_github_principal

  depends_on = [google_project_service.required_apis]
}

module "artifact_registry" {
  source = "../modules/artifact-registry"

  project_id    = var.project_id
  location      = var.region
  repository_id = "${var.environment}-docker-repo"
  description   = "Docker repository for ${var.environment} environment"

  labels = {
    environment = var.environment
  }

  immutable_tags = false

  depends_on = [google_project_service.required_apis]
}

module "buckets" {
  source     = "../modules/buckets"
  project_id = var.project_id

  buckets = {
    # "${var.project_id}-tfstate-${var.environment}" = {
    #   location        = "EU"
    #   versioning      = true
    #   prevent_destroy = true
    # }

    "${var.project_id}-app-${var.environment}" = {
      location   = "EU"
      versioning = false
    }
  }


  depends_on = [google_project_service.required_apis]
}

module "cloudsql" {
  source = "../modules/cloudsql"

  project_id    = var.project_id
  region        = var.region
  instance_name = "${var.environment}-pg"

  db_name     = "app"
  db_user     = "appuser"
  db_password = var.db_password

  depends_on = [google_project_service.required_apis]
}

module "pubsub" {
  source     = "../modules/pubsub"
  project_id = var.project_id

  depends_on = [google_project_service.required_apis]
}

module "gke" {
  source = "../modules/gke"

  project_id   = var.project_id
  cluster_name = "${var.environment}-gke"

  cluster_zone = "europe-west3-a"
  node_zones   = ["europe-west3-a", "europe-west3-b"]

  network_name = module.vpc.network_name
  subnet_name  = module.vpc.subnet_name

  # you must create these secondary ranges in your subnet (next step)
  pods_range_name     = "pods-range"
  services_range_name = "services-range"

  master_ipv4_cidr_block = "172.16.0.0/28"

  authorized_networks_cidr = "0.0.0.0/0"

  machine_type = "e2-highcpu-4"

  gke_events_topic_id = module.pubsub.gke_events_topic_id

  cloudsql_sa_email = module.iam.cloudsql_sa_email

  depends_on = [module.vpc, module.pubsub, google_project_service.required_apis, module.iam]
}



# module "notify_gke_events" {
#   source = "../modules/notification-service"

#   project_id     = var.project_id
#   region         = var.region
#   function_name  = "${var.environment}-notify-gke"

#   topic_id = module.pubsub.gke_events_topic_id

#   to_email   = var.notify_to_email
#   from_email = var.notify_from_email

#   smtp_user         = var.smtp_user
#   smtp_app_password = var.smtp_app_password

#   source_bucket = var.functions_source_bucket
#   source_object = var.functions_source_object

#   depends_on = [google_project_service.required_apis, module.pubsub]
# }

# module "notify_monitoring_alerts" {
#   source = "../modules/notification-service"

#   project_id     = var.project_id
#   region         = var.region
#   function_name  = "${var.environment}-notify-monitoring"

#   topic_id = module.pubsub.monitoring_alerts_topic_id

#   to_email   = var.notify_to_email
#   from_email = var.notify_from_email

#   smtp_user         = var.smtp_user
#   smtp_app_password = var.smtp_app_password

#   source_bucket = var.functions_source_bucket
#   source_object = var.functions_source_object

#   depends_on = [google_project_service.required_apis, module.pubsub]
# }

module "ingress_ip" {
  source     = "../modules/ingress-ip"
  project_id = var.project_id
  name       = "${var.environment}-gke-ingress-ip"
}

