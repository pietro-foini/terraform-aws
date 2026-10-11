resource "aws_instance" "chatbot_server" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = "t3.small"
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "chatbot-server"
  }

  # Only at the creation step.
  user_data = <<-EOF
              #!/bin/bash
              set -e

              # System update and Docker installlation + jq
              dnf update -y
              dnf install -y docker jq
              systemctl enable --now docker
              usermod -aG docker ec2-user

              # Get dynamically environment variable
              REGION="${var.region}"
              ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
              ECR_REPO="${data.aws_ecr_repository.ml_servers.name}"
              IMAGE_TAG="latest"

              # Login on ECR and pull image
              aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com
              docker pull $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$ECR_REPO:$IMAGE_TAG

              # Retrieve Secrets Manager
              SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id ${data.aws_secretsmanager_secret.ml_secrets.name} --region $REGION --query SecretString --output text)
              DB_USER=$(echo $SECRET_JSON | jq -r .postgres_db_username)
              DB_PASSWORD=$(echo $SECRET_JSON | jq -r .postgres_db_password)
              SECRET_KEY=$(echo $SECRET_JSON | jq -r .auth_key)

              # Start Container Docker
              docker run -d \
                --name chatbot-service \
                --restart always \
                -p 8000:8000 \
                -e PORT=8000 \
                -e AWS_DEFAULT_REGION=$REGION \
                -e AWS_REGION=$REGION \
                -e CLOUD_PROVIDER="aws" \
                -e ENVIRONMENT="cloud" \
                -e LLM_MODEL="amazon.nova-lite-v1:0" \
                -e EMBEDDINGS_MODEL="amazon.titan-embed-text-v2:0" \
                -e DB_NAME="${data.aws_db_instance.postgres.db_name}" \
                -e DB_HOST="${data.aws_db_instance.postgres.address}" \
                -e DB_PORT=5432 \
                -e DB_USER="$DB_USER" \
                -e DB_PASSWORD="$DB_PASSWORD" \
                -e SECRET_KEY="$SECRET_KEY" \
                -e STORAGE_BUCKET="${aws_s3_bucket.chatbot_bucket.id}" \
                -e COOKIE_SECURE="false" \
                $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$ECR_REPO:$IMAGE_TAG
              EOF
}