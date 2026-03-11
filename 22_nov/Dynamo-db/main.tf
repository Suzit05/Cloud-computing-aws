provider "aws" {
  region = "eu-north-1"
}

resource "aws_dynamodb_table" "mytable" {
  name = "Employees"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "EmpId"
    type = "S"
  }
  hash_key = "EmpId"
}

output "mytable_output" {
  value = aws_dynamodb_table.mytable.arn
}