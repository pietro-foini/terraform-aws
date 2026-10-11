resource "aws_db_instance" "postgres" {
  identifier        = "postgres"
  engine            = "postgres"
  engine_version    = "18.3"
  instance_class    = "db.t4g.micro"
  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = "chatbot"
  username = var.postgres_user
  password = random_password.postgres_pwd.result

  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = true

  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    team = "ml"
  }
}
