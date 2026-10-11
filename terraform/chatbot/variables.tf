variable "account_name" {
  description = "AWS account name"
  type        = string
}

variable "region" {
  description = "Main AWS region"
  type        = string
}

variable "github_branch_pattern" {
  description = "Git branch to monitor for the trigger"
  type        = string
}

variable "git_repository_link_id" {
  description = "Full resource ID of the Developer Connect Git Repository Link"
  type        = string
}
