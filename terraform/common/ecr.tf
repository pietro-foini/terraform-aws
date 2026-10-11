resource "aws_ecr_repository" "ml_servers" {
  name                 = "ml-servers"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  tags = {
    team = "ml"
  }
}
