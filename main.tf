provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}

# S3 bucket
resource "aws_s3_bucket" "flugel" {
  bucket = "${var.bucket_name}"
  acl    = "private"

  tags = {
    Name        = "Flugel Test"
    Environment = "Dev"
  }
}
# S3 Objects
resource "aws_s3_bucket_object" "object_1" {
  bucket = "${aws_s3_bucket.flugel.id}"
  key    = "test1.txt"
        content = "${timestamp()}"
}
resource "aws_s3_bucket_object" "object_2" {
  bucket = "${aws_s3_bucket.flugel.id}"
  key    = "test2.txt"
        content = "${timestamp()}"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  
  tags = {
    Name = "Flugel"
  }
}

# Security Groups
resource "aws_security_group" "alb_sg" {
  name          = "${var.alb_sg_name}"
  vpc_id        = "${aws_vpc.main.id}"
  tags = {
    Name = "flugel_allow_http"
  }
  # Allow inbound HTTP requests
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow all outbound requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}