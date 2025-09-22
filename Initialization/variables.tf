variable "region" {
  default = "us-east-1"
}

variable "bucket_name" {
  description = "Globally unique S3 bucket name"
  type        = string
}

variable "dynamodb_table" {
  description = "Name of DynamoDB table for locks"
  type        = string
}



variable "environment" {
  default = "dev"
}
variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "Gad-Project-ITI"
}