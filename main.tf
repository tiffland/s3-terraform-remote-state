terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  backend "s3" {
    bucket         = "terraform-remote-state-test-42"
    key            = "global/s3/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "s3-remote-state-lock"
    encrypt        = true
  }

  required_version = ">= 0.14.9"
}



provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

resource "aws_s3_bucket" "s3-remote-state" {
  bucket = "terraform-remote-state-test-42"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "s3-remote-state-lock" {
  hash_key     = "LockID"
  name         = "s3-remote-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_instance" "app_server" {
  ami           = "ami-0453cb7b5f2b7fca2"
  instance_type = "t2.micro"

  tags = {
    Name = "ExampleAppServerInstance"
  }
}

