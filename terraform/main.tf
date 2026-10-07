terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  required_version = ">= 1.6.0"
}

provider "aws" {
  region = "ap-southeast-2"
}
data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
resource "aws_instance" "devops_web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  key_name = "devops-project-key"
  vpc_security_group_ids = [aws_security_group.devops_web_sg.id]

  tags = {
    Name = "devops-web-server"
  }
}
output "ec2_public_ip" {
  value = aws_instance.devops_web.public_ip
}
resource "aws_security_group" "devops_web_sg" {
  name        = "devops-web-sg"
  description = "Allow SSH access"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["153.117.21.17/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops-web-sg"
  }
}