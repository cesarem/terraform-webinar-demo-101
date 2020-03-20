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


<<<<<<< HEAD
output "bucket_id" {
  value = "${aws_s3_bucket.flugel.id}"
}


=======
>>>>>>> c86bb90d9a89c71004539cb0d3e32e169be2dbb4
