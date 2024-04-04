# GitHub Actions

The following example shows you how to configure Workload Identity Federation via Terraform IaC for GitHub Actions.

## Example

With this example the following steps are executed and configured:

1. Create Workload Identity Pool Provider for GitHub
1. Create new service account for GitHub Actions
1. Allow login via Workload Identity Provider and limit login only from the GitHub organization and repository
1. Output the Workload Identity Pool Provider resource name for GitHub Actions configuration

> An example of a working GitHub Actions configuration can be found [here](https://github.com/Cyclenerd/google-workload-identity-federation/blob/master/.github/workflows/auth.yml).

<!-- BEGIN_TF_DOCS -->

```hcl
# Create Workload Identity Pool Provider for GitHub and restrict access to GitHub organization
module "github-wif" {
  source     = "Cyclenerd/wif-github/google"
  version    = "~> 1.0.0"
  project_id = var.project_id
  # Restrict access to username or the name of a GitHub organization
  attribute_condition = "assertion.repository_owner == '${var.github_organization}'"
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
  version    = "~> 1.0.0"
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
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_github_account_id"></a> [github\_account\_id](#input\_github\_account\_id) | The account id of the service account for GitHub Actions | `string` | n/a | yes |
| <a name="input_github_organization"></a> [github\_organization](#input\_github\_organization) | The username or the name of a GitHub organization | `string` | n/a | yes |
| <a name="input_github_repository"></a> [github\_repository](#input\_github\_repository) | The GitHub repository | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_github-workload-identity-provider"></a> [github-workload-identity-provider](#output\_github-workload-identity-provider) | The Workload Identity Provider resource name |
<!-- END_TF_DOCS -->
