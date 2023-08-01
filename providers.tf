terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.10.0"
    }
  }
}

provider "aws" {
  shared_config_files      = ["/Users/someshwarkarmakar/.aws/config"]
  shared_credentials_files = ["/Users/someshwarkarmakar/.aws/credentials"]
  profile                  = "credential"
}