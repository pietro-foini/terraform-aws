resource "aws_db_subnet_group" "rds" {
  name        = "ml-rds-subnet-group"
  subnet_ids  = data.aws_subnets.default.ids
  description = "Subnet group for PostgreSQL RDS"
}

resource "aws_security_group" "rds" {
  name        = "ml-rds-sg"
  description = "Inbound rules for RDS PostgreSQL firewall"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "PostgreSQL IP allowed"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // TODO: change fore real scenarios
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
