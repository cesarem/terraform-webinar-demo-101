provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}

resource "aws_s3_bucket" "flugel" {
  bucket = "flugel-test1-bucket"
  acl    = "private"

  tags = {
    Name        = "Flugel Test"
    Environment = "Dev"
  }
}

resource "local_file" "test1" {
  content   = timestamp()
  filename  = "${path.module}/test1.txt"
}

resource "local_file" "test2" {
  content   = timestamp()
  filename  = "${path.module}/test2.txt"
}

resource "aws_s3_bucket_object" "test1_file" {
  bucket = aws_s3_bucket.flugel.id
  key    = "test1.txt"
  source = "${path.module}/test1.txt"
}

resource "aws_s3_bucket_object" "test2_file" {
  bucket = aws_s3_bucket.flugel.id
  key    = "test2.txt"
  source = "${path.module}/test2.txt"
}