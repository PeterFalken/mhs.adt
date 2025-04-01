# https://registry.terraform.io/providers/hashicorp/google/latest
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "> 6.0.0"
    }
  }
}

provider "google" {
  # credentials = file("<PATH_TO_SERVICE_ACCOUNT_JSON>")
  project = "DEFAULT_PROJECT_ID"
  region  = "us-central1"
  zone    = "us-central1-c"
}


resource "google_project" "gc_project" {
  name       = "SMT Take Home Exercise - ${var.yourname}"
  project_id = "smt-the-${var.environment}-${var.yourname}-${random_string.rand4char.result}"
}

output "project_id" {
  value = google_project.gc_project.project_id
}

# Modules
module "cloud_function" {
  source      = "./modules/cloud_function"
  environment = var.environment
  regions     = var.regions
}

module "network" {
  source         = "./modules/network"
  environment    = var.environment
  regions        = var.regions
  subnet_cidr    = var.subnet_cidr
  cloud_function = module.cloud_function.gc_function
}
