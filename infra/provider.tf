provider "aws" {
  region = var.region
  version = "~> 3.23"
}

data "aws_caller_identity" "current" {}

terraform {
  required_version = "= 0.12.29"
  required_providers {
    aws = {
      version = "~> 3.23"
    }
  }
}
