resource "google_compute_network" "vpc_adt" {
  auto_create_subnetworks = false
  name                    = "adt-network"
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "subnet_adt" {
  name          = "example"
  ip_cidr_range = var.subnet_cidr
  region        = "us-central1"
  network       = google_compute_network.vpc_adt.id
}

resource "google_compute_firewall" "cloud_func_ingress" {
  name    = "adt-cf-http-ingress"
  network = google_compute_network.vpc_adt.id

  ## Allow pings
  allow {
    protocol = "icmp"
  }

  # Allow HTTP/HTTPS calls
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
}
