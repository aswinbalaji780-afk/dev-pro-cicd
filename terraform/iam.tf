resource "aws_iam_role" "ec2_ecr_role" {
  name = "ec2-ecr-pull-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

}

resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  role       = aws_iam_role.ec2_ecr_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-ecr-instance-profile"
  role = aws_iam_role.ec2_ecr_role.name
}


# 1. Create the policy allowing access to your GitHub CodeConnection
resource "aws_iam_policy" "codebuild_connections_policy" {
  name        = "codebuild-connections-use-policy"
  description = "Allows CodeBuild to use the GitHub connection"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "codeconnections:UseConnection",
          "codeconnections:GetConnection"
        ]
        Resource = "arn:aws:codeconnections:ap-southeast-2:195231313161:connection/56e32440-3879-439a-8837-e15ff2917fbb"
      }
    ]
  })
}

# 2. Attach this policy directly to your CodeBuild role
resource "aws_iam_role_policy_attachment" "codebuild_connections_attach" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_connections_policy.arn
}
