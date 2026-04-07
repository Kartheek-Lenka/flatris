provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "flatris" {
  ami           = "ami-0f5ee92e2d63afc18" # Ubuntu (ap-south-1)
  instance_type = "t2.micro"
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.flatris_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y nodejs npm git
              npm install -g yarn
              cd /home/ubuntu
              git clone https://github.com/${var.github_repo}.git app
              cd app/web
              yarn install
              yarn build
              nohup yarn start > app.log 2>&1 &
              EOF

  tags = {
    Name = "flatris-server"
  }
}

resource "aws_security_group" "flatris_sg" {
  name = "flatris-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
