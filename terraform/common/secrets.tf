resource "random_password" "postgres_pwd" {
  length  = 16
  special = false
}

resource "random_password" "auth_pwd" {
  length  = 64
  special = false
  upper   = false
  lower   = true
  numeric = true
}

resource "aws_secretsmanager_secret" "ml_secrets" {
  name                    = "ml-secrets"
  recovery_window_in_days = 0

  tags = {
    team = "ml"
  }
}

resource "aws_secretsmanager_secret_version" "ml_secrets_val" {
  secret_id = aws_secretsmanager_secret.ml_secrets.id

  secret_string = jsonencode({
    postgres_db_username = var.postgres_user
    postgres_db_password = random_password.postgres_pwd.result
    auth_key             = random_password.auth_pwd.result
  })

  lifecycle {
    ignore_changes = [
      secret_string,
    ]
  }
}
