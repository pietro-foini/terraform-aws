variable "account_name" {
  description = "AWS account name"
  type        = string
}

variable "region" {
  description = "Main AWS region"
  type        = string
}

variable "postgres_user" {
  type        = string
  description = "The name of the user for PostgreSQL database"
}
