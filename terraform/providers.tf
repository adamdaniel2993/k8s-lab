terraform {
  backend "s3" {
    bucket = "cbord-terraform-state"
    key    = "axd3/k8s-lab/terraform.tfstate"
    region = "us-east-1"
  }


  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.0.0"
    }
  }
}

provider "aws" {
  region = var.region
  assume_role {
    role_arn = var.target_account
  }
  default_tags {
    tags = {
      Terraform = "Yes"
    }
  }
}