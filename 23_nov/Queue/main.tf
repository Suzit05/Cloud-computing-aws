terraform {
  required_version = ">=1.0"
  required_providers {
    aws={
        source = "hashicorp/aws"
        version = "~>5.0"
    }
  }
}


provider "aws" {
  region = "eu-north-1"
}


#    1.      dlq

resource "aws_sqs_queue" "dlq" {
  name = "my-dead-letter-queue"
  message_retention_seconds = 1209600 #14 days
}

# 2. main sqs queue

resource "aws_sqs_queue" "main_q" {
    name = "my-main-queue"
    visibility_timeout_seconds = 30 #message hidden time after being picked
    delay_seconds = 0
    max_message_size = 261445 #240kb
    # attach dlq to main q
    redrive_policy =jsonencode({
        deadLetterTargetArn= aws_sqs_queue.dlq.arn
        maxReceiveCount = 3 #after 3 failed attempts ---> move to DLQ
    })
  
}

#3.     output

output "mainq_url" {
  value = aws_sqs_queue.main_q.url
}

output "mainq_arn" {
  value = aws_sqs_queue.main_q.arn
}


output "dlq_urlv" {
  value = aws_sqs_queue.dlq.url
}

output "dlq_arn" {
  value = aws_sqs_queue.dlq.arn
}