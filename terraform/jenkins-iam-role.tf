resource "aws_iam_role" "jenkins_role" {
  name = "jenkins-ecr-push-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "ec2.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })
}


resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "jenkins-ecr-instance-profile"
  role = aws_iam_role.jenkins_role.name
}


resource "aws_iam_role_policy_attachment" "jenkins_ssm" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}
