# 1. Request a permanent Static IP from AWS
resource "aws_eip" "jenkins_static_ip" {
  instance = aws_instance.jenkins_server.id
  domain   = "vpc" # Tells AWS to assign it inside your custom VPC
}

# 2. Update your terminal Output block to use the permanent IP
output "jenkins_url1" {
  value = "http://${aws_eip.jenkins_static_ip.public_ip}:8080"
}
