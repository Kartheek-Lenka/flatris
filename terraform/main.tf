# ── Security Group ─────────────────────────────────────────
resource "aws_security_group" "flatris_sg" {
  name        = "${var.project_name}-sg"
  description = "Allow HTTP, HTTPS and SSH"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "App port"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project = var.project_name
  }
}

# ── EC2 Instance (Free Tier) ───────────────────────────────
resource "aws_instance" "flatris" {
  ami                    = "ami-0f5ee92e2d63afc18" # Ubuntu 22.04 LTS ap-south-1
  instance_type          = "t2.micro"              # Free tier
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.flatris_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nodejs npm git
    npm install -g pm2
    npm install -g n
    n 18
    hash -r
  EOF

  tags = {
    Name    = "${var.project_name}-server"
    Project = var.project_name
  }
}

# ── Elastic IP (so public IP never changes) ────────────────
resource "aws_eip" "flatris" {
  instance = aws_instance.flatris.id
  domain   = "vpc"

  tags = {
    Project = var.project_name
  }
}
