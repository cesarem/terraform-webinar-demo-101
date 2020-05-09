provider "aws" {
  region     = "us-east-2"
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "example" {
  ami             = "ami-03ffa9b61e8d2cfda"
  instance_type   = "t2.nano"
  key_name        = "aws-ec2-servers_ohio"
  security_groups = [aws_security_group.allow_ssh.name]
  tags		        = {Name = "kt_walk-through"}
}

module "kt_test" {
  source = "../../.."
  
  bucket_name       = var.bucket_name          
  alb_sg_name       = var.alb_sg_name
  instance_sg_name  = var.instance_sg_name
  alb_name          = var.alb_name
  server_port       = var.server_port
  ec2_image_id      = var.ec2_image_id
  instance_type     = var.instance_type
  region            = var.region
  ssh_key           = var.ssh_key
}