provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}

resource "aws_s3_bucket" "flugel" {
  bucket = "${var.bucket_name}"
  acl    = "private"

  tags = {
    Name        = "Flugel Test"
    Environment = "Dev"
  }
}


