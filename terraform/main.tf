## Network

resource "google_compute_subnetwork" "gke-subnet" {
  name          = "gke-subnet"
  ip_cidr_range = "10.2.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.network.self_link
  secondary_ip_range {
    range_name    = "us-central1-01-gke-01-pods"
    ip_cidr_range = "192.168.10.0/24"
  }
  secondary_ip_range {
    range_name    = "us-central1-01-gke-01-services"
    ip_cidr_range = "192.168.11.0/24"
  }
}

resource "google_compute_network" "network" {
  name                    = "network"
  auto_create_subnetworks = false
}

## Kubernetes

module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google"
  version = "8.1.0"

  project_id                 = "cheapvpn"
  name                       = "gke-1"
  region                     = "us-central1"
  zones                      = ["us-central1-f"]
  network                    = google_compute_network.network.name
  subnetwork                 = "gke-subnet"
  ip_range_pods              = "us-central1-01-gke-01-pods"
  ip_range_services          = "us-central1-01-gke-01-services"
  http_load_balancing        = false
  horizontal_pod_autoscaling = true
  network_policy             = true

  node_pools = [
    {
      name               = "default-node-pool"
      machine_type       = "g1-small"
      min_count          = 1
      max_count          = 1
      local_ssd_count    = 0
      disk_size_gb       = 30
      disk_type          = "pd-standard"
      image_type         = "COS"
      auto_repair        = true
      auto_upgrade       = true
      preemptible        = true
      initial_node_count = 1
    },
  ]

}


