provider "aws" {
  region = var.region
}


resource "aws_dynamodb_table" "users" {
  name = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "Email"   #primary key (partiton key)
    type = "S"   #STRING
  }
  #can store more attributes also
  hash_key = "Email"
  tags = {
    PROJECT = "User Management"
    AUTHOR = "Sujeet kr"
  }
}


output "table_name" {
  value = aws_dynamodb_table.users.name
  description = "the name of the table"
}

output "dynamodb_arn" {
  value = aws_dynamodb_table.users.arn
  description = "dynamo db arn or unique path"  #unique id 
}