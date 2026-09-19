resource "aws_instance" "web_server" {
  ami                  = "ami-0e045913e61b9cef6"
  instance_type        = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  subnet_id                   = aws_subnet.main.id
  vpc_security_group_ids      = [aws_security_group.web_ssh_access.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.devops_key.key_name

  user_data = <<-EOF
  #!/bin/bash

  dnf install docker -y
  systemctl start docker
  systemctl enable docker

  aws ecr get-login-password --region ap-southeast-2 | \
  docker login --username AWS --password-stdin \
  195231313161.dkr.ecr.ap-southeast-2.amazonaws.com

  docker pull 195231313161.dkr.ecr.ap-southeast-2.amazonaws.com/my-web:latest

  docker run -d -p 80:80 --name my-web \
  195231313161.dkr.ecr.ap-southeast-2.amazonaws.com/my-web:latest
EOF



  tags = {
    Name = "DevOps-Web-Server"
  }

}




