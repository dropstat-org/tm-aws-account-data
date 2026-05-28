terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"

  # Assumes TerraformCI in the dev account via GitHub Actions OIDC.
  # For local runs, omit assume_role and export AWS_PROFILE instead.
  assume_role {
    role_arn = "arn:aws:iam::ACCOUNT_ID:role/TerraformCI"
  }
}
