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

output "bucket_id" {
  value = "${aws_s3_bucket.flugel.id}"
}
