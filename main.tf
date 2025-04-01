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
  project = "adt-takehome"
  region  = "us-central1"
  zone    = "us-central1-c"
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
