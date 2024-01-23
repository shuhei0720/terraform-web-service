terraform {
  # バックエンドを指定
  backend "s3" {
    bucket = "web-service-prod-tfstate-276229188355"
    key = "terraform.tfstate"
    region = "ap-northeast-1"
  }
  
  # Terraformのバージョン指定
  required_version = ">= 1.4.6"

  # プロバイダのバージョン指定
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

# プロバイダを指定
provider "aws" {
  region = "ap-northeast-1"
}
