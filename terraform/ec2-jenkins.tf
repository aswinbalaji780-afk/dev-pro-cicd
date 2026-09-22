resource "aws_instance" "jenkins_server" {
  ami                  = "ami-0e045913e61b9cef6"
  instance_type        = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.jenkins_profile.name

  subnet_id                   = aws_subnet.main.id
  vpc_security_group_ids      = [aws_security_group.web_ssh_access.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.devops_key.key_name

  root_block_device {
    volume_size           = 15    # 15 GB of storage space
    volume_type           = "gp3" # General Purpose SSD (fast and free-tier safe)
    delete_on_termination = true
  }

  user_data = <<-EOF
  #!/bin/bash

  set -e

  # 1. Install required packages
  dnf install -y wget curl java-21-amazon-corretto

  # 2. Create Jenkins repository
  tee /etc/yum.repos.d/jenkins.repo > /dev/null <<'REPO'
[jenkins]
name=Jenkins-stable
baseurl=https://pkg.jenkins.io/rpm-stable
gpgcheck=1
gpgkey=https://pkg.jenkins.io/rpm-stable/jenkins.io-2026.key
enabled=1
REPO

  # 3. Import Jenkins GPG key
  rpm --import https://pkg.jenkins.io/rpm-stable/jenkins.io-2026.key

  # 4. Refresh package cache
  dnf clean all
  dnf makecache

  # 5. Install Jenkins
  dnf install -y jenkins

  # 6. Enable and start Jenkins
  systemctl daemon-reload
  systemctl enable jenkins
  systemctl start jenkins

  # 7. Standard Docker daemon installation
  dnf install -y docker

  # 8. Enable and start Docker
  systemctl enable docker
  systemctl start docker

  # 9. Add Jenkins user to Docker group
  usermod -aG docker jenkins

  # 10. Restart Jenkins
  systemctl restart jenkins

  # 11. Verify Jenkins and Docker
  systemctl is-active --quiet jenkins
  systemctl is-active --quiet docker

  echo "Jenkins installation completed"
  echo "Docker installation completed"
EOF
  tags = {
    Name = "Jenkins-Build-Server"
  }
}

output "jenkins_url" {
  value = "http://${aws_instance.jenkins_server.public_ip}:8080"
}
