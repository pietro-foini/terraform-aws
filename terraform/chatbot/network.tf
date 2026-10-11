resource "aws_security_group" "ec2" {
  name        = "ml-ec2-sg"
  description = "Security Group for Chatbot EC2 instance"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "FastAPI HTTP API"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "ec2_to_rds" {
  type                     = "ingress"
  description              = "Allow PostgreSQL access from Chatbot EC2"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ec2.id
  security_group_id        = tolist(data.aws_db_instance.postgres.vpc_security_groups)[0]
}
