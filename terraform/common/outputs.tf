output "secrets_manager_arn" {
  description = "ARN of the Secrets Manager secret containing database credentials and auth key"
  value       = aws_secretsmanager_secret.ml_secrets.arn
}

output "secrets_manager_name" {
  description = "Name of the Secrets Manager secret to be fetched by the container"
  value       = aws_secretsmanager_secret.ml_secrets.name
}

output "rds_endpoint" {
  description = "Endpoint (host) for the database PostgreSQL"
  value       = aws_db_instance.postgres.address
}

output "rds_port" {
  description = "Port of the database PostgreSQL"
  value       = aws_db_instance.postgres.port
}

output "rds_security_group_id" {
  description = "ID Security Group RDS"
  value       = aws_security_group.rds.id
}

