provider "google" {
  credentials = file("tfuser-my-challenge-project.json")

  project = "my-challenge-project-265703"
  region  = "us-central1"
  zone    = "us-central1-a"
}


resource "google_compute_network" "main" {
  name                    = "main"
  auto_create_subnetworks = false
}


resource "google_compute_subnetwork" "public" {
  name          = "public"
  ip_cidr_range = "10.0.0.0/24"
  region        = "us-central1"
  network       = google_compute_network.main.id
  # depends_on    = ["google_compute_network.vpc.name"]

}



resource "google_compute_subnetwork" "private" {
  name          = "private"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.main.id

}

# cloud router
resource "google_compute_router" "router" {
  name    = "router"
  network = google_compute_network.main.id
  bgp {
    asn            = 64514
    advertise_mode = "CUSTOM"
  }
}

# resource "google_compute_router_nat" "nat" {
#   name                               = "nat"
#   router                             = google_compute_router.router.name
#   region                             = google_compute_router.router.region
#   nat_ip_allocate_option             = "AUTO_ONLY"
#   source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

#   subnetwork {
#     name                    = "private"
#     source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
#   }

# }


resource "google_compute_instance" "myappserver" {
  name         = "primary-application-server"
  zone         = "us-central1-a"
  machine_type = "f1-micro"

  tags = ["name", "myappserver"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }



  network_interface {
    network    = google_compute_network.main.name
    subnetwork = google_compute_subnetwork.public.name

    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    foo = "bar"
  }
}
