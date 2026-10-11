data "aws_vpc" "default" {
  default = true
}

data "aws_secretsmanager_secret" "ml_secrets" {
  name = "ml-secrets"
}

data "aws_db_instance" "postgres" {
  db_instance_identifier = "postgres"
}

data "aws_ecr_repository" "ml_servers" {
  name = "ml-servers"
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}