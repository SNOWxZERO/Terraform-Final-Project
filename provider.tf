provider "aws" {
  shared_config_files      = ["conf"]
  shared_credentials_files = ["creds"]
  profile                  = "default"
}


terraform {
  backend "s3" {
    bucket         = "terraform-states-muhammadgad"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks-muhammadgad"
  }
}
