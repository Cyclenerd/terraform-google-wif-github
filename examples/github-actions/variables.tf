variable "project_id" {
  type        = string
  description = "The ID of the project"
}

variable "github_account_id" {
  type        = string
  description = "The account id of the service account for GitHub Actions"
}

variable "github_organization" {
  type        = string
  description = "The username or the name of a GitHub organization"
}

variable "github_repository" {
  type        = string
  description = "The GitHub repository"
}