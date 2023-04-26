/**
 * Copyright 2023 Nils Knieling
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# GOOGLE PROJECT

variable "project_id" {
  type        = string
  description = "The ID of the project"
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Invalid project ID!"
  }
}

# IDENTITY POOL

variable "pool_id" {
  type        = string
  description = "Workload Identity Pool ID"
  default     = "github-com"
  validation {
    condition = substr(var.pool_id, 0, 4) != "gcp-" && length(regex("([a-z0-9-]{4,32})", var.pool_id)) == 1
    error_message = join(" ", [
      "The 'pool_id' value should be 4-32 characters, and may contain the characters [a-z0-9-].",
      "The prefix 'gcp-' is reserved and can't be used in a pool ID."
    ])
  }
}

variable "pool_display_name" {
  type        = string
  description = "Workload Identity Pool display name"
  default     = "github.com"
}

variable "pool_description" {
  type        = string
  description = "Workload Identity Pool description"
  default     = "Workload Identity Pool for GitHub (Terraform managed)"
}

variable "pool_disabled" {
  type        = bool
  description = "Workload Identity Pool disabled"
  default     = false
}

# IDENTITY POOL PROVIDER

variable "provider_id" {
  type        = string
  description = "Workload Identity Pool Provider ID"
  default     = "github-com-oidc"
  validation {
    condition = substr(var.provider_id, 0, 4) != "gcp-" && length(regex("([a-z0-9-]{4,32})", var.provider_id)) == 1
    error_message = join(" ", [
      "The 'provider_id' value should be 4-32 characters, and may contain the characters [a-z0-9-].",
      "The prefix 'gcp-' is reserved and can't be used in a provider ID."
    ])
  }
}

variable "provider_display_name" {
  type        = string
  description = "Workload Identity Pool Provider display name"
  default     = "github.com OIDC"
}

variable "provider_description" {
  type        = string
  description = "Workload Identity Pool Provider description"
  default     = "Workload Identity Pool Provider for GitHub (Terraform managed)"
}

variable "provider_disabled" {
  type        = bool
  description = "Workload Identity Pool Provider disabled"
  default     = false
}

variable "issuer_uri" {
  type        = string
  description = "Workload Identity Pool Provider issuer URI"
  default     = "https://token.actions.githubusercontent.com"
}

variable "attribute_mapping" {
  type        = map(string)
  description = "Workload Identity Pool Provider attribute mapping"
  default = {
    # Default attributes used in:
    # https://registry.terraform.io/modules/Cyclenerd/wif-service-account/google/latest
    "google.subject"       = "assertion.sub"        # Subject
    "attribute.sub"        = "attribute.sub"        # Subject
    "attribute.actor"      = "assertion.actor"      # The personal account that initiated the workflow run.
    "attribute.repository" = "assertion.repository" # The repository from where the workflow is running
    # More
    # https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#understanding-the-oidc-token
    "attribute.actor_id"              = "assertion.actor_id"              # The ID of personal account that initiated the workflow run.
    "attribute.base_ref"              = "assertion.base_ref"              # The target branch of the pull request in a workflow run.
    "attribute.environment"           = "assertion.environment"           # The name of the environment used by the job.
    "attribute.event_name"            = "assertion.event_name"            # The name of the event that triggered the workflow run.
    "attribute.head_ref"              = "assertion.head_ref"              # The source branch of the pull request in a workflow run.
    "attribute.job_workflow_ref"      = "assertion.job_workflow_ref"      # For jobs using a reusable workflow, the ref path to the reusable workflow. For more information, see "Using OpenID Connect with reusable workflows."
    "attribute.job_workflow_sha"      = "assertion.job_workflow_sha"      # For jobs using a reusable workflow, the commit SHA for the reusable workflow file.
    "attribute.ref"                   = "assertion.ref"                   # (Reference) The git ref that triggered the workflow run.
    "attribute.ref_type"              = "assertion.ref_type"              # The type of ref, for example: "branch".
    "attribute.repository_visibility" = "assertion.repository_visibility" # The visibility of the repository where the workflow is running. Accepts the following values: internal, private, or public.
    "attribute.repository_id"         = "assertion.repository_id"         # The ID of the repository from where the workflow is running.
    "attribute.repository_owner"      = "assertion.repository_owner"      # The name of the organization in which the repository is stored.
    "attribute.repository_owner_id"   = "assertion.repository_owner_id"   # The ID of the organization in which the repository is stored.
    "attribute.run_id"                = "assertion.run_id"                # The ID of the workflow run that triggered the workflow.
    "attribute.run_number"            = "assertion.run_number"            # The number of times this workflow has been run.
    "attribute.run_attempt"           = "assertion.run_attempt"           # The number of times this workflow run has been retried.
    "attribute.runner_environment"    = "assertion.runner_environment"    # The type of runner used by the job. Accepts the following values: github-hosted or self-hosted.
    "attribute.workflow"              = "assertion.workflow"              # The name of the workflow.
    "attribute.workflow_ref"          = "assertion.workflow_ref"          # The ref path to the workflow. For example, octocat/hello-world/.github/workflows/my-workflow.yml@refs/heads/my_branch.
    "attribute.workflow_sha"          = "assertion.workflow_sha"          # The commit SHA for the workflow file.
  }
}

variable "attribute_condition" {
  type        = string
  description = "(Optional) Workload Identity Pool Provider attribute condition expression"
  default     = null
}