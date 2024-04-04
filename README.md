# Google Cloud Workload Identity for GitHub

[![Badge: Google Cloud](https://img.shields.io/badge/Google%20Cloud-%234285F4.svg?logo=google-cloud&logoColor=white)](https://github.com/Cyclenerd/terraform-google-wif-github#readme)
[![Badge: Terraform](https://img.shields.io/badge/Terraform-%235835CC.svg?logo=terraform&logoColor=white)](https://github.com/Cyclenerd/terraform-google-wif-github#readme)
[![Badge: GitHub](https://img.shields.io/badge/GitHub-181717.svg?logo=github&logoColor=white)](https://github.com/Cyclenerd/terraform-google-wif-github#readme)
[![Badge: CI](https://github.com/Cyclenerd/terraform-google-wif-github/actions/workflows/ci.yml/badge.svg)](https://github.com/Cyclenerd/terraform-google-wif-github/actions/workflows/ci.yml)
[![Badge: License](https://img.shields.io/github/license/cyclenerd/terraform-google-wif-github)](https://github.com/Cyclenerd/terraform-google-wif-github/blob/master/LICENSE)

This Terraform module creates a Workload Identity Pool and Provider for GitHub.

Service account keys are a security risk if compromised.
Avoid service account keys and instead use the [Workload Identity Federation](https://github.com/Cyclenerd/google-workload-identity-federation#readme).
For more information about Workload Identity Federation and how to best authenticate service accounts on Google Cloud, please see my GitHub repo [Cyclenerd/google-workload-identity-federation](https://github.com/Cyclenerd/google-workload-identity-federation#readme).

> There are also a ready-to-use Terraform modules
> for [GitLab](https://github.com/Cyclenerd/terraform-google-wif-gitlab#readme)
> and [Bitbucket](https://github.com/Cyclenerd/terraform-google-wif-bitbucket#readme).

## Example

> **Warning**
> GitHub use a single issuer URL across all organizations and some of the claims embedded in OIDC tokens might not be unique to your organization.
> To help protect against spoofing threats, you must use an attribute condition that restricts access to tokens issued by your GitHub organization.

Create Workload Identity Pool and Provider:

```hcl
# Create Workload Identity Pool Provider for GitHub and restrict access to GitHub organization
module "github-wif" {
  source     = "Cyclenerd/wif-github/google"
  version    = "~> 1.0.0"
  project_id = var.project_id
  # Restrict access to username or the name of a GitHub organization
  attribute_condition = "assertion.repository_owner == '${var.github_organization}'"
}

# Get the Workload Identity Pool Provider resource name for GitHub Actions configuration
output "github-workload-identity-provider" {
  description = "The Workload Identity Provider resource name"
  value       = module.github-wif.provider_name
}
```

> An example of a working GitHub Actions configuration can be found [here](https://github.com/Cyclenerd/google-workload-identity-federation/blob/master/.github/workflows/auth.yml).

Allow service account to login via Workload Identity Provider and limit login only from the GitHub repository `octo-org/octo-repo`:

```hcl
# Get existing service account for GitHub Actions
data "google_service_account" "github" {
  project    = var.project_id
  account_id = "existing-account-for-github-action"
}

# Allow service account to login via WIF and only from GitHub repository
module "github-service-account" {
  source     = "Cyclenerd/wif-service-account/google"
  version    = "~> 1.0.0"
  project_id = var.project_id
  pool_name  = module.github-wif.pool_name
  account_id = data.google_service_account.github.account_id
  repository = "octo-org/octo-repo"
}
```

> Terraform module [`Cyclenerd/wif-service-account/google`](https://github.com/Cyclenerd/terraform-google-wif-service-account) is used.

👉 [**More examples**](https://github.com/Cyclenerd/terraform-google-wif-github/tree/master/examples)

## OIDC Token Attribute Mapping

> The attributes `attribute.sub` and `attribute.repository` are used in the Terrform module [Cyclenerd/wif-service-account/google](https://github.com/Cyclenerd/terraform-google-wif-service-account).
> Please do not remove these attributes.

Default attribute mapping:

| Attribute                         | Claim                             | Description |
|-----------------------------------|-----------------------------------|-------------|
| `google.subject`                  | `assertion.sub`                   | Subject
| `attribute.sub`                   | `assertion.sub`                   | Defines the subject claim that is to be validated by the cloud provider. This setting is essential for making sure that access tokens are only allocated in a predictable way.
| `attribute.repository`            | `assertion.repository`            | The repository from where the workflow is running
| `attribute.aud`                   | `assertion.aud`                   | Audience
| `attribute.iss`                   | `assertion.iss`                   | The issuer of the OIDC token: `https://token.actions.githubusercontent.com`
| `attribute.actor`                 | `assertion.actor`                 | The personal account that initiated the workflow run.
| `attribute.actor_id`              | `assertion.actor_id`              | The ID of personal account that initiated the workflow run.
| `attribute.base_ref`              | `assertion.base_ref`              | The target branch of the pull request in a workflow run.
| `attribute.environment`           | `assertion.environment`           | The name of the environment used by the job.
| `attribute.event_name`            | `assertion.event_name`            | The name of the event that triggered the workflow run.
| `attribute.head_ref`              | `assertion.head_ref`              | The source branch of the pull request in a workflow run.
| `attribute.job_workflow_ref`      | `assertion.job_workflow_ref`      | For jobs using a reusable workflow, the ref path to the reusable workflow. For more information, see [Using OpenID Connect with reusable workflows](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/using-openid-connect-with-reusable-workflows).
| `attribute.job_workflow_sha`      | `assertion.job_workflow_sha`      | For jobs using a reusable workflow, the commit SHA for the reusable workflow file.
| `attribute.ref`                   | `assertion.ref`                   | (Reference) The git ref that triggered the workflow run.
| `attribute.ref_type`              | `assertion.ref_type`              | The type of `ref`, for example: "branch".
| `attribute.repository_visibility` | `assertion.repository_visibility` | The visibility of the repository where the workflow is running. Accepts the following values: `internal`, `private`, or `public`.
| `attribute.repository_id`         | `assertion.repository_id`         | The ID of the repository from where the workflow is running.
| `attribute.repository_owner`      | `assertion.repository_owner`      | The name of the organization in which the `repository` is stored.
| `attribute.repository_owner_id`   | `assertion.repository_owner_id`   | The ID of the organization in which the `repository` is stored.
| `attribute.run_id`                | `assertion.run_id`                | The ID of the workflow run that triggered the workflow.
| `attribute.run_number`            | `assertion.run_number`            | The number of times this workflow has been run.
| `attribute.run_attempt`           | `assertion.run_attempt`           | The number of times this workflow run has been retried.
| `attribute.runner_environment`    | `assertion.runner_environment`    | The type of runner used by the job. Accepts the following values: `github-hosted` or `self-hosted`.
| `attribute.workflow`              | `assertion.workflow`              | The name of the workflow.
| `attribute.workflow_ref`          | `assertion.workflow_ref`          | The ref path to the workflow. For example, `octocat/hello-world/.github/workflows/my-workflow.yml@refs/heads/my_branch`.
| `attribute.workflow_sha`          | `assertion.workflow_sha`          | The commit SHA for the workflow file.

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 4.62.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attribute_condition"></a> [attribute\_condition](#input\_attribute\_condition) | (Optional) Workload Identity Pool Provider attribute condition expression | `string` | `null` | no |
| <a name="input_attribute_mapping"></a> [attribute\_mapping](#input\_attribute\_mapping) | Workload Identity Pool Provider attribute mapping | `map(string)` | <pre>{<br>  "attribute.actor": "assertion.actor",<br>  "attribute.actor_id": "assertion.actor_id",<br>  "attribute.aud": "attribute.aud",<br>  "attribute.base_ref": "assertion.base_ref",<br>  "attribute.environment": "assertion.environment",<br>  "attribute.event_name": "assertion.event_name",<br>  "attribute.head_ref": "assertion.head_ref",<br>  "attribute.iss": "attribute.iss",<br>  "attribute.job_workflow_ref": "assertion.job_workflow_ref",<br>  "attribute.job_workflow_sha": "assertion.job_workflow_sha",<br>  "attribute.ref": "assertion.ref",<br>  "attribute.ref_type": "assertion.ref_type",<br>  "attribute.repository": "assertion.repository",<br>  "attribute.repository_id": "assertion.repository_id",<br>  "attribute.repository_owner": "assertion.repository_owner",<br>  "attribute.repository_owner_id": "assertion.repository_owner_id",<br>  "attribute.repository_visibility": "assertion.repository_visibility",<br>  "attribute.run_attempt": "assertion.run_attempt",<br>  "attribute.run_id": "assertion.run_id",<br>  "attribute.run_number": "assertion.run_number",<br>  "attribute.runner_environment": "assertion.runner_environment",<br>  "attribute.sub": "attribute.sub",<br>  "attribute.workflow": "assertion.workflow",<br>  "attribute.workflow_ref": "assertion.workflow_ref",<br>  "attribute.workflow_sha": "assertion.workflow_sha",<br>  "google.subject": "assertion.sub"<br>}</pre> | no |
| <a name="input_issuer_uri"></a> [issuer\_uri](#input\_issuer\_uri) | Workload Identity Pool Provider issuer URI | `string` | `"https://token.actions.githubusercontent.com"` | no |
| <a name="input_pool_description"></a> [pool\_description](#input\_pool\_description) | Workload Identity Pool description | `string` | `"Workload Identity Pool for GitHub (Terraform managed)"` | no |
| <a name="input_pool_disabled"></a> [pool\_disabled](#input\_pool\_disabled) | Workload Identity Pool disabled | `bool` | `false` | no |
| <a name="input_pool_display_name"></a> [pool\_display\_name](#input\_pool\_display\_name) | Workload Identity Pool display name | `string` | `"github.com"` | no |
| <a name="input_pool_id"></a> [pool\_id](#input\_pool\_id) | Workload Identity Pool ID | `string` | `"github-com"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project | `string` | n/a | yes |
| <a name="input_provider_description"></a> [provider\_description](#input\_provider\_description) | Workload Identity Pool Provider description | `string` | `"Workload Identity Pool Provider for GitHub (Terraform managed)"` | no |
| <a name="input_provider_disabled"></a> [provider\_disabled](#input\_provider\_disabled) | Workload Identity Pool Provider disabled | `bool` | `false` | no |
| <a name="input_provider_display_name"></a> [provider\_display\_name](#input\_provider\_display\_name) | Workload Identity Pool Provider display name | `string` | `"github.com OIDC"` | no |
| <a name="input_provider_id"></a> [provider\_id](#input\_provider\_id) | Workload Identity Pool Provider ID | `string` | `"github-com-oidc"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_pool_id"></a> [pool\_id](#output\_pool\_id) | Identifier for the pool |
| <a name="output_pool_name"></a> [pool\_name](#output\_pool\_name) | Name for the pool |
| <a name="output_pool_state"></a> [pool\_state](#output\_pool\_state) | State of the pool |
| <a name="output_provider_id"></a> [provider\_id](#output\_provider\_id) | Identifier for the provider |
| <a name="output_provider_name"></a> [provider\_name](#output\_provider\_name) | The resource name of the provider |
| <a name="output_provider_state"></a> [provider\_state](#output\_provider\_state) | State of the provider |
<!-- END_TF_DOCS -->

## License

All files in this repository are under the [Apache License, Version 2.0](LICENSE) unless noted otherwise.

Based on [Terraform module for workload identity federation on GCP](https://github.com/mscribellito/terraform-google-workload-identity-federation) by [Michael S](https://github.com/mscribellito).
