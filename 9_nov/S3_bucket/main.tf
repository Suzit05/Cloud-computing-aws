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

#default vpc
data "aws_vpc" "default" {
  default = true
}

#iam role

resource "aws_iam_role" "flask_role" {
  name = "flask_ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# policy attachment

resource "aws_iam_role_policy_attachment" "s3_access" {
  
  role = aws_iam_role.flask_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

#iam instance profile

resource "aws_iam_instance_profile" "flask_profile" {
  name = "flask-ec2-instance-profile"
  role = aws_iam_role.flask_role.name
  
}

#sg

resource "aws_security_group" "flask_sg" {
  name = "flask-sg"
  description = "security group for ssh and flask app"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    from_port = 5000
    to_port = 5000
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

resource "aws_key_pair" "flask_key" {
  key_name = "flask-key"
  public_key = file("/mnt/c/Users/sujee/.ssh/id_rsa.pub") # ssh -i ~/.ssh/id_rsa ubuntu@13.48.105.151
}


resource "aws_instance" "flask_app" {
  ami = "ami-073130f74f5ffb161" #ubuntu
  instance_type = "t3.micro"
  associate_public_ip_address = true
  key_name = aws_key_pair.flask_key.key_name
  iam_instance_profile = aws_iam_instance_profile.flask_profile.name
  vpc_security_group_ids = [ aws_security_group.flask_sg.id ]
  tags = {
    Name = "flask-app"
  }
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y python3-pip awscli
              sudo pip3 install flask boto3

              mkdir -p /home/ubuntu/flask_app
              cd /home/ubuntu/flask_app

              cat <<'PYEOF' > app.py
              from flask import Flask, render_template_string, request
              import boto3

              app = Flask(__name__)

              S3_BUCKET = "${aws_s3_bucket.upload_bucket.bucket}"
              S3_REGION = "eu-north-1"
              s3 = boto3.client("s3", region_name=S3_REGION)

              HTML_FORM = '''
              <!DOCTYPE html>
              <html lang="en">
              <head>
                  <meta charset="UTF-8">
                  <meta name="viewport" content="width=device-width, initial-scale=1.0">
                  <title>Upload Image</title>
                  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
              </head>
              <body class="bg-light">
                  <div class="container mt-5">
                      <div class="card shadow p-4">
                          <h3 class="text-center text-primary mb-4">Upload Image to AWS S3</h3>
                          <form action="/upload" method="post" enctype="multipart/form-data">
                              <div class="mb-3">
                                  <input type="file" name="file" class="form-control" required>
                              </div>
                              <button type="submit" class="btn btn-success w-100">Upload</button>
                          </form>
                      </div>
                  </div>
              </body>
              </html>
              '''

              @app.route('/')
              def home():
                  return render_template_string(HTML_FORM)

              @app.route('/upload', methods=['POST'])
              def upload():
                  file = request.files['file']
                  if file:
                      s3.upload_fileobj(file, S3_BUCKET, file.filename)
                      url = f"https://{S3_BUCKET}.s3.{S3_REGION}.amazonaws.com/{file.filename}"
                      return f"✅ File uploaded successfully! Access it <a href='{url}'>{url}</a>"

              if __name__ == '__main__':
                  app.run(host='0.0.0.0', port=5000)
              PYEOF

              cd /home/ubuntu/flask_app
              nohup python3 app.py > app.log 2>&1 &
              EOF

}
output "bucket_name" {
  value = aws_s3_bucket.upload_bucket.bucket
}

output "flask_app_url" {
value = "http://${aws_instance.flask_app.public_ip}:5000"
}