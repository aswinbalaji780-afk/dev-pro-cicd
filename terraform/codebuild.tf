resource "aws_codebuild_project" "docker_build" {
  name         = "dev-pro-docker-build"
  description  = "Build Docker image and push it to Amazon ECR"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = "ap-southeast-2"
    }

    environment_variable {
      name  = "ECR_REPOSITORY_URI"
      value = "195231313161.dkr.ecr.ap-southeast-2.amazonaws.com/my-web"
    }
  }

  source {
    type     = "GITHUB"
    location = "https://github.com/aswinbalaji780-afk/dev-pro-cicd.git"
    auth {
      type     = "CODECONNECTIONS"
      resource = "arn:aws:codeconnections:ap-southeast-2:195231313161:connection/56e32440-3879-439a-8837-e15ff2917fbb"
    }
  }

  source_version = "main"

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }
}
