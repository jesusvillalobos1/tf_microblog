# Version 2 for BIg APP using terraform as backend
# Resource to create S3 bucket for storing remote state file
resource "aws_s3_bucket" "big-app-tf-backend" {
  bucket = "big-app-tf-backend"
  versioning {
    enabled = true
  }
  lifecycle {
    # Change to true on Prod
    prevent_destroy = false
  }
  tags = {
    Name = "Terraform S3 Remote State Store"
  }
}

resource "aws_dynamodb_table" "terraform-state-lock" {
  name           = "terraform-state-lock"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    Name = "Terraform State Lock Table"
  }
}

resource "aws_s3_bucket_policy" "s3-bigapp-bc" {
    bucket = aws_s3_bucket.big-app-tf-backend.id
    policy = jsonencode({
    "Id": "Policy1643155501080",
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Stmt1563401284635",
            "Action": [
                "s3:GetObject",
                "s3:ListBucket",
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:s3:::big-app-tf-backend",

        }
    ]
    })
}