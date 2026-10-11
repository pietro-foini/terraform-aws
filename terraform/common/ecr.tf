resource "aws_ecr_repository" "ml_servers" {
  name                 = "ml-servers"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = false
  }

  tags = {
    team = "ml"
  }
}
