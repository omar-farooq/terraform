terraform {
  backend "gcs" {
    credentials = "~/auth/google-key.json"
    bucket  = "zah-terraform"
  }
}

resource "google_service_account" "zah-tf" {
  account_id = "zah-tf"
  display_name = "Zah Terraform Service Account"
}

resource "google_service_account" "zah_registry_user" {
  account_id = "zah-registry-user"
  display_name = "Artifact registry service account"
}

resource "google_service_account_key" "tf-key" {
  service_account_id    = google_service_account.zah-tf.name
}

#resource "local_file" "key" {
#  filename = "google-key.json"
#  content = "${base64decode(google_service_account_key.tf-key.private_key)}"
#}

module "zah_project_services" {
  source = "../modules/gcp_project_services"
  services = ["cloudresourcemanager.googleapis.com", "cloudbilling.googleapis.com", "compute.googleapis.com", "iam.googleapis.com", "storage.googleapis.com", "serviceusage.googleapis.com", "artifactregistry.googleapis.com", "secretmanager.googleapis.com"]
}

module "projects_iam_bindings" {
  source  = "terraform-google-modules/iam/google//modules/projects_iam"
  version = "~> 7.7"

  projects = ["zah-website"]

  bindings = {
    "roles/storage.admin" = [
      "serviceAccount:${google_service_account.zah-tf.email}",
    ]

    "roles/compute.networkAdmin" = [
      "serviceAccount:${google_service_account.zah-tf.email}",
    ]

    "roles/iam.workloadIdentityPoolAdmin" = [
      "serviceAccount:${google_service_account.zah-tf.email}",
    ]

    "roles/compute.instanceAdmin.v1" = [
      "serviceAccount:${google_service_account.zah-tf.email}",
    ]

    "roles/compute.securityAdmin" = [
      "serviceAccount:${google_service_account.zah-tf.email}",
    ]

    "roles/editor" = [
      "serviceAccount:${google_service_account.zah-tf.email}",
    ]

    "roles/iam.serviceAccountTokenCreator" = [
      "serviceAccount:${google_service_account.zah_registry_user.email}",
    ]

    "roles/artifactregistry.writer" = [
      "serviceAccount:${google_service_account.zah_registry_user.email}",
    ]
  }
}

module "vpc" {
    source  = "terraform-google-modules/network/google"
    version = "~> 9.0"

    project_id   = "zah-website"
    network_name = "zah-vpc"
    routing_mode = "GLOBAL"

    subnets = [
        {
            subnet_name           = "subnet-01"
            subnet_ip             = "10.0.10.0/24"
            subnet_region         = "us-east1"
        },
    ]

    routes = [
        {
            name                   = "egress-internet"
            description            = "route through IGW to access internet"
            destination_range      = "0.0.0.0/0"
            tags                   = "egress-inet"
            next_hop_internet      = "true"
        },
    ]

    ingress_rules = [
        {
            name = "webserver"
            source_ranges = ["0.0.0.0/0"]
            allow = [
                {
                    protocol = "tcp",
                    ports = ["22", "80", "443"]
                }
            ]
        }
    ]
}

resource "google_compute_disk" "website_disk" {
  name = "zah-website-disk"
  type = "pd-standard"
  zone = "us-east1-b"
  size = 20
  labels = {
    vm = "zah"
    managedby = "terraform"
  }
}

resource "google_compute_instance" "zah" {
  name = "zah"
  machine_type = "e2-micro"
  zone = "us-east1-b"
  can_ip_forward = "true"
  allow_stopping_for_update = "true"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  attached_disk {
    source = google_compute_disk.website_disk.self_link
    device_name = google_compute_disk.website_disk.name
  }

  network_interface {
    network = module.vpc.network_name
    subnetwork = module.vpc.subnets_names[0]
    access_config {}
  }

  metadata = {
    ssh-keys = "${var.username}:${file(var.ssh_pub_key)}"
  }

  scheduling {
    automatic_restart = true
  }

  lifecycle {
    ignore_changes = [attached_disk]
  }

  service_account {
    email = "231388685322-compute@developer.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }
}

resource "google_artifact_registry_repository" "zah" {
  location      = "us-east1"
  repository_id = "zah"
  description   = "repository for zah docker images"
  format        = "DOCKER"
}

resource "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = "zah-github"
  display_name              = "zah github identity pool"
  description               = "Identity pool for github actions"
  project                   = "zah-website" 
}

resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id             = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id    = "zah-github-provider"
  display_name                          = "Zah Github OIDC provider"
  attribute_condition                   = "assertion.repository_owner == 'omar-farooq'"
  attribute_mapping                     = {
    "google.subject"                = "assertion.sub"
    "attribute.actor"               = "assertion.actor"
    "attribute.repository"          = "assertion.repository"
    "attribute.repository_owner"    = "assertion.repository_owner"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_secret_manager_secret" "secret-basic" {
  secret_id = "zah-github-secret"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_iam_binding" "binding" {
  project = "zah-website"
  secret_id = google_secret_manager_secret.secret-basic.secret_id
  role = "roles/secretmanager.secretAccessor"
  members = [
    "principalSet://iam.googleapis.com/projects/231388685322/locations/global/workloadIdentityPools/zah-github/attribute.repository/omar-farooq/zah"
  ]
}

resource "google_service_account_iam_binding" "artifact-sa" {
  service_account_id = google_service_account.zah_registry_user.name 
  role = "roles/iam.workloadIdentityUser"
  
  members = [
    "principalSet://iam.googleapis.com/projects/231388685322/locations/global/workloadIdentityPools/zah-github/attribute.repository/omar-farooq/zah"    
  ]
}

resource "google_storage_bucket" "zah_housing" {
  name = "zah-housing"
  location = "us-east1"
  uniform_bucket_level_access = true
}

resource "cloudflare_zone" "zah" {
  account_id = "c481cd0068116b3efb7c163c8d2a0b38"
  zone       = "zah.org.uk"
}

resource "cloudflare_record" "sendgrid_cname_1" {
  zone_id = cloudflare_zone.zah.id
  name    = "url2589.zah.org.uk"
  type    = "CNAME"
  value   = "sendgrid.net"
}

resource "cloudflare_record" "sendgrid_cname_2" {
  zone_id = cloudflare_zone.zah.id
  name    = "43635762.zah.org.uk"
  type    = "CNAME"
  value   = "sendgrid.net"
}

resource "cloudflare_record" "sendgrid_cname_3" {
  zone_id = cloudflare_zone.zah.id
  name    = "em1994.zah.org.uk"
  type    = "CNAME"
  value   = "u43635762.wl013.sendgrid.net"
}

resource "cloudflare_record" "sendgrid_cname_4" {
  zone_id = cloudflare_zone.zah.id
  name    = "s1._domainkey.zah.org.uk"
  type    = "CNAME"
  value   = "s1.domainkey.u43635762.wl013.sendgrid.net"
}

resource "cloudflare_record" "sendgrid_cname_5" {
  zone_id = cloudflare_zone.zah.id
  name    = "s2._domainkey.zah.org.uk"
  type    = "CNAME"
  value   = "s2.domainkey.u43635762.wl013.sendgrid.net"
}
