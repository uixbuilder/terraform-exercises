variable "stack_name" {
  description = "The name of the CloudFormation stack."
  type        = string
  default     = "terraform-cfn-repro-stack"
}

variable "bucket_name" {
  description = "The name of the S3 bucket to be created by the CloudFormation stack."
  type        = string
  default     = "terraform-cfn-repro-bucket-2023"
}