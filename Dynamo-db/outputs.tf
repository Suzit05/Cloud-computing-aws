output "table_name" {
  description = "the name of the dynamo table"
  value = aws_dynamodb_table.mytable.name
}

output "dynamodb_arn" {
  description = "the arn of the dynamo db table"
  value = aws_dynamodb_table.mytable.arn
}