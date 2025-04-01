resource "google_compute_region_network_endpoint_group" "net_endp_grp" {
  for_each              = toset(var.regions)
  name                  = "function-neg"
  network_endpoint_type = "SERVERLESS"
  region                = each.key
  cloud_function {
    function = var.cloud_function[each.key]
  }
}

# https://cloud.google.com/blog/topics/developers-practitioners/new-terraform-module-serverless-load-balancing
module "lb-http" {
  # source  = "GoogleCloudPlatform/lb-http/google//modules/serverless_negs"
  source  = "GoogleCloudPlatform/lb-http/google"
  version = "> 12"
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
        enable = false
      }

      description = "Default endpoints"
      # custom_request_headers = null
      # security_policy        = null

      ## Health checks
      health_check = {
        check_interval_sec = 10
        timeout_sec        = 5
        logging            = true
      }
    }
  }
}
