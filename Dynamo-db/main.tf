provider "aws" {
  region = "eu-north-1"
}

resource "aws_dynamodb_table" "dynamodb_table" {
  name = var.table_name
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "USER ID"
    type = "S"
  }

  hash_key = "USERID"
  range_key = "EMAIL"
  
  attribute {
    name = "EMAIL"
    type = "S"
  }

  tags = {
    Name = var.table_name
    Environment = "Dev"
  }


}