resource "google_compute_region_network_endpoint_group" "net_endp_grp" {
  name                  = "function-neg"
  network_endpoint_type = "SERVERLESS"
  region                = "us-central1"
  cloud_function {
    function = google_cloudfunctions2_function.function.name
  }
}

# https://cloud.google.com/blog/topics/developers-practitioners/new-terraform-module-serverless-load-balancing
module "lb-http" {
  source  = "GoogleCloudPlatform/lb-http/google//modules/serverless_negs"
  version = "~> 4.5"
  project = "adt-takehome"
  name    = "lb-cloudfunc"

  managed_ssl_certificate_domains = ["${var.environment}.takehome.adt.com"]
  ssl                             = true
  https_redirect                  = true

  backends = {
    default = {
      groups = [
        {
          group = google_compute_region_network_endpoint_group.net_endp_grp.id
        }
      ]

      enable_cdn = false

      log_config = {
        enable      = true
        sample_rate = 1.0
      }

      iap_config = {
        enable               = false
        oauth2_client_id     = null
        oauth2_client_secret = null
      }

      description            = null
      custom_request_headers = null
      security_policy        = null
    }
  }
}
