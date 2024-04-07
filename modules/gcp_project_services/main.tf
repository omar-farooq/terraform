resource "google_project_service" "services" {
  for_each = var.services
  service = each.key
}
