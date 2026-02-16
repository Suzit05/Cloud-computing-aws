provider "aws" {
  region = "eu-north-1"
}

resource "random_id" "randomid" {
  byte_length = 4
}

resource "aws_s3_bucket" "upload_bucket" {
  bucket = "flask-upload-suzit-${random_id.randomid.hex}"
  tags = {
    Name = "FlaskuploadBucket"
    Environment = "Dev"
  }
}

output "bucket_name" {
  value = aws_s3_bucket.upload_bucket.bucket
}