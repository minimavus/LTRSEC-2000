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

#Create Private Subnet
resource "aws_subnet" "pod-private-subnet" {
  vpc_id     = aws_vpc.pod-vpc.id
  cidr_block = "10.${var.pod_number}.0.0/24"

  tags = {
    Name = "ISEinAWS-pod${var.pod_number}_Private_Subnet"
    Created = "${local.formatted_date}"
  }
}

#Create Transit Gateway Attachment
resource "aws_ec2_transit_gateway_vpc_attachment" "zer0k-transit-gateway" {
  subnet_ids         = [aws_subnet.pod-private-subnet.id]
  transit_gateway_id = "${var.zer0k_transit_gateway}"
  vpc_id             = aws_vpc.pod-vpc.id

  tags = {
    Name = "ISEinAWS-pod${var.pod_number}_Transit_Attach"
    Created = "${local.formatted_date}"
  }
}

#Create Private Route Table
resource "aws_route_table" "pod-private-rt" {
  vpc_id = aws_vpc.pod-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    transit_gateway_id = "${var.zer0k_transit_gateway}"
  }

  tags = {
    Name = "ISEinAWS-pod${var.pod_number}_Transit_Attach"
    Created = "${local.formatted_date}"
  }
}

#Attach the Route Table to the Subnet
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.pod-private-subnet.id
  route_table_id = aws_route_table.pod-private-rt.id
}