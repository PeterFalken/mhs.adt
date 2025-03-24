resource "google_compute_region_network_endpoint_group" "net_endp_grp" {
  for_each              = toset(var.regions)
  name                  = "function-neg"
  network_endpoint_type = "SERVERLESS"
  region                = each.key
  cloud_function {
    function = google_cloudfunctions2_function.gc_function.name
  }
}

# https://cloud.google.com/blog/topics/developers-practitioners/new-terraform-module-serverless-load-balancing
module "lb-http" {
  source  = "GoogleCloudPlatform/lb-http/google//modules/serverless_negs"
  version = "~> 9.0"
  project = "adt-takehome"
  name    = "lb-cloudfunc"

  load_balancing_scheme           = "EXTERNAL"
  managed_ssl_certificate_domains = ["${var.environment}.takehome.adt.com"]
  ssl                             = true
  https_redirect                  = true

  backends = {
    default = {
      groups = [
        for neg in google_compute_region_network_endpoint_group.net_endp_grp :
        {
          group = neg.id
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

    ## Health checks
    outlier_detection = {
      base_ejection_time = {
        seconds = 10
      }
      consecutive_errors = optional(number)
      interval = {
        seconds = number
      }
    }
  }
}
