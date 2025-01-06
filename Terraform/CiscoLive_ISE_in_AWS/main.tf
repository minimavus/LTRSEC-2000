# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

locals {
  formatted_date = formatdate("YYYY-MM-DD", timestamp())
}

provider "aws" {
  region = "us-east-2"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  default_tags {
    tags = {
      Pod = "pod${var.pod_number}"
      Project = "LTRSEC-2000"
    }
  }
}

#Create Pod VPC
resource "aws_vpc" "pod-vpc" {
  cidr_block = "10.${var.pod_number}.0.0/16"
  tags = {
    Name = "ISEinAWS-pod${var.pod_number}"
    Created = "${local.formatted_date}"
  }
}