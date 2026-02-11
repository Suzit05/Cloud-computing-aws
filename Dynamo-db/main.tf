provider "aws" {
  region = "eu-north-1"
}

resource "aws_dynamodb_table" "mytable" {
  name = var.table_name
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "USERID"
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

resource "aws_key_pair" "server_key" {
  key_name = "server_key"
  public_key = file("/mnt/c/Users/sujee/.ssh/id_rsa.pub")
}

resource "aws_security_group" "mysg" {
  name = "mysg"
  description = "Allow http and server access"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    from_port = 3000
    to_port = 3000
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

resource "aws_instance" "deploy_app" {
  ami = "ami-0c83cb1c664994bbd" #amzn linux
  instance_type = var.instance_type
  security_groups = [ aws_security_group.mysg.name]
  key_name = aws_key_pair.server_key.key_name
  user_data = file("deploy_js.sh")  
}