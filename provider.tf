provider "aws" {
  shared_config_files      = ["./conf"]
  shared_credentials_files = ["./creds"]
  profile                  = "dev"
}

terraform {
  backend "s3" {
    bucket = "terraform-states-muhammadgad"
    key    = "dev/terraform.tfstate"
    region = "us-east-1"
  }
}

