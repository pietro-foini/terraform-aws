resource "aws_codebuild_project" "chatbot_build" {
  name          = "ml-chatbot"
  description   = "Docker build and push to ECR for chatbot"
  service_role  = aws_iam_role.codebuild_role.arn
  build_timeout = 20

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/amazonlinux2-x86_64-standard:6.0"
    type         = "LINUX_CONTAINER"

    privileged_mode = true
  }

  source {
    type            = "GITHUB"
    location        = var.git_repository_link_id
    buildspec       = "cloud/aws/buildspec.yml"
    git_clone_depth = 1
  }
}

resource "aws_codebuild_webhook" "chatbot_webhook" {
  project_name = aws_codebuild_project.chatbot_build.name
  build_type   = "BUILD"

  pull_request_build_policy {
    requires_comment_approval = "DISABLED"
  }

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH"
    }

    filter {
      type    = "HEAD_REF"
      pattern = var.github_branch_pattern
    }
  }
}
