# https://registry.terraform.io/providers/hashicorp/google/latest
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.25.0"
    }
  }
}

provider "google" {
  project = "adt-takehome"
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_service_account" "service_account" {
  account_id   = "sa-gcf"
  display_name = "Google Cloud Function Service Account"
}


# Modules
module "network" {
  source      = "./modules/network"
  subnet_cird = "10.10.240.0/16"
}

module "cloud_function" {
  source      = "./modules/cloud_function"
  bucket_name = "gcf-bucket"
}
