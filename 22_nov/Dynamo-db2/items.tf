#########################################################
# Sample  User 1
########################################################


resource "aws_dynamodb_table_item" "users1" {
  table_name = aws_dynamodb_table.users.name
  hash_key = "Email"

  item = <<ITEM
  {
  "Email"      :{"S": "ajaykumar@gmail.com"},
  "Password"   :{"S":  "ajay#&*49"},
  "Name"       :{"S":  "Ajay Thakur"},
  "Designation" :{"S":  "Developer"}
  }
  ITEM
}

#########################################################
# Sample  User 2
########################################################


resource "aws_dynamodb_table_item" "users2" {
  table_name = aws_dynamodb_table.users.name
  hash_key = "Email"

  item = <<ITEM
  {
  "Email"      :{"S": "Kabir22@gmail.com"},
  "Password"   :{"S":  "kabirs#&*49"},
  "Name"       :{"S":  "Kabir kishore"},
  "Designation" :{"S":  "Cloud Engeineer"}
  }
  ITEM
}