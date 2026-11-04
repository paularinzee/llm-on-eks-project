terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # >= 5.81 makes thumbprint_list optional on aws_iam_openid_connect_provider
      version = ">= 5.81"
    }
  }
}

provider "aws" {
  region = var.region

  # CFN tagged most resources with `project`; default_tags applies it everywhere.
  default_tags {
    tags = {
      project = var.project_tag
    }
  }
}
