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

resource "local_file" "test_files" {
  count     = 2
  content   = timestamp()
  filename  = "./test${count.index + 1}.txt"
}

resource "aws_s3_bucket_object" "file_object" {
  count  = 2
  bucket = aws_s3_bucket.flugel.id
  key    = "test${count.index + 1}.txt"
  source = "./test${count.index + 1}.txt"
  
  depends_on = [local_file.test_files]
}