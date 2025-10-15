terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1" # Or your preferred region
}

resource "aws_cloudformation_stack" "repro_stack" {
  name = var.stack_name

  template_body = file("${path.module}/template.yaml")

  parameters = {
    S3BucketName = var.bucket_name
  }
}