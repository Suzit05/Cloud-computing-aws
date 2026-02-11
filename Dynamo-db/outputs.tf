output "table_name" {
  description = "the name of the dynamo table"
  value = aws_dynamodb_table.mytable.name
}

output "dynamodb_arn" {
  description = "the arn of the dynamo db table"
  value = aws_dynamodb_table.mytable.arn
}

output "deploy_app_url" {
  description = "the ip address of the app"
  value = aws_instance.deploy_app.public_ip
}