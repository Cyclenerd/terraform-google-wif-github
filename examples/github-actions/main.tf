# Create Workload Identity Pool Provider for GitHub
module "github-wif" {
  source     = "Cyclenerd/wif-github/google"
  version    = "1.0.0"
  project_id = var.project_id
}

# Create new service account for GitHub Actions
resource "google_service_account" "github" {
  project      = var.project_id
  account_id   = var.github_account_id
  display_name = "GitHub Actions (WIF)"
  description  = "Service Account for GitHub Actions ${var.github_repository} (Terraform managed)"
}

# Allow service account to login via WIF and only from GitHub repository
module "github-service-account" {
  source     = "Cyclenerd/wif-service-account/google"
  version    = "1.0.0"
  project_id = var.project_id
  pool_name  = module.github-wif.pool_name
  account_id = google_service_account.github.account_id
  repository = var.github_repository
  depends_on = [google_service_account.github]
}

# Get the Workload Identity Pool Provider resource name for GitHub Actions configuration
output "github-workload-identity-provider" {
  description = "The Workload Identity Provider resource name"
  value       = module.github-wif.provider_name
}