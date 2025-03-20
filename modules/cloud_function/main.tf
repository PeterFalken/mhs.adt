resource "google_storage_bucket" "bucket" {
  name                        = "gcf-source-${var.environment}"
  location                    = "US"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "object" {
  name   = "function_source.zip"
  bucket = google_storage_bucket.bucket.name
  source = "function_source.zip" # Add path to the zipped function source code
}

resource "google_cloudfunctions2_function" "function" {
  name        = "helloworld-${var.environment}"
  location    = "us-central1"
  description = "ADT-HelloWorld"

  build_config {
    runtime     = "python312"
    entry_point = "hello_http"
    source {
      storage_source {
        bucket = google_storage_bucket.bucket.name
        object = google_storage_bucket_object.object.name
      }
    }
  }

  service_config {
    min_instance_count = 1
    max_instance_count = 10
    available_memory   = "128M"
    timeout_seconds    = 15
  }
}
