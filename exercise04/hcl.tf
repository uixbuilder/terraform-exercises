terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket_name
}

data "aws_s3_bucket" "my_external_bucket" {
  bucket = "not-managed-by-us"
}

variable "bucket_name" {
  type        = string
  description = "The name of the S3 bucket to create"
  default = "my-default-bucket-name"
}

output "bucket_id" {
  value = aws_s3_bucket.my_bucket.id
}

locals {
  local_example = "This is a local value"
}

module "my_module" {
  source = "./module_example"
}