resource "google_storage_bucket" "bucket_gcf_source" {
  name                        = "gcf-source-${var.environment}"
  location                    = "US"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "storage_object" {
  name   = "function_source.zip"
  bucket = google_storage_bucket.bucket.name
  source = "function_source.zip" # Add path to the zipped function source code
}

resource "google_storage_bucket_access_control" "bucket_read_access" {
  bucket = google_storage_bucket.bucket_gcf_source.name
  role   = "READER"
  entity = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_storage_bucket" "audit-log-bucket" {
  name                        = "gcf-auditlog-bucket"
  location                    = "us-central1"
  uniform_bucket_level_access = true
}

resource "google_cloudfunctions2_function" "gc_function" {
  for_each    = toset(var.regions)
  name        = "helloworld-${var.environment}"
  location    = each.key
  description = "ADT-HelloWorld"

  build_config {
    runtime     = "python312"
    entry_point = "hello_http"
    source {
      storage_source {
        bucket = google_storage_bucket.bucket_gcf_source.name
        object = google_storage_bucket_object.storage_object.name
      }
    }
  }

  service_config {
    min_instance_count = 1
    max_instance_count = 10
    available_memory   = "32M"
    ingress_settings   = "ALLOW_INTERNAL_ONLY"
    timeout_seconds    = 15
  }

  event_trigger {
    trigger_region        = "us-central1"
    event_type            = "google.cloud.audit.log.v1.written"
    retry_policy          = "RETRY_POLICY_RETRY"
    service_account_email = google_service_account.account.email
    event_filters {
      attribute = "serviceName"
      value     = "storage.googleapis.com"
    }
    event_filters {
      attribute = "methodName"
      value     = "storage.objects.create"
    }
    event_filters {
      attribute = "resourceName"
      value     = "/projects/_/buckets/${google_storage_bucket.audit-log-bucket.name}/objects/*.txt"
      operator  = "match-path-pattern"
    }
  }
}

resource "google_cloudfunctions2_function_iam_member" "invoker" {
  project        = google_cloudfunctions2_function.gc_function.project
  location       = google_cloudfunctions2_function.gc_function.location
  cloud_function = google_cloudfunctions2_function.gc_function.name
  role           = "roles/cloudfunctions.invoker"
  member         = "serviceAccount:${google_service_account.service_account.email}"
}

output "function_uri" {
  value = google_cloudfunctions2_function.gc_function.service_config[0].uri
}
