output "table_name" {
  description = "the name of the dynamo table"
  value = aws_dynamodb_table.dynamodb_table.name
}

output "dynamodb arn" {
  description = "the arn of the dynamo db table"
  value = aws_dynamodb_table.dynamodb_table.arn
}