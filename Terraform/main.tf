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
  # Calculate the DNS server IP as the base address of the VPC's CIDR block plus 2
  dns_server_ip = cidrhost(aws_vpc.pod-vpc.cidr_block, 2)
  ntp_server_ip = "169.254.169.123"
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

#Create Security Group for ISE
resource "aws_security_group" "ise-security-group" {
  name        = "ISEinAWS-pod${var.pod_number}_Security_Group"
  description = "Allow Management of ISE"
  vpc_id      = aws_vpc.pod-vpc.id

  tags = {
    Name = "ISEinAWS-pod${var.pod_number}_Security_Group"
    Created = "${local.formatted_date}"
  }
}

resource "aws_security_group_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.ise-security-group.id
  type              = "ingress"
  cidr_blocks       = ["${var.zer0k_inside_subnet}", "${var.zer0k_vpn_subnet}", "${var.zer0k_entravpn_subnet}"]
  from_port         = 443
  protocol          = "tcp"
  to_port           = 443
}

resource "aws_security_group_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.ise-security-group.id
  type              = "ingress"
  cidr_blocks       = ["${var.zer0k_inside_subnet}", "${var.zer0k_vpn_subnet}", "${var.zer0k_entravpn_subnet}"]
  from_port         = 22
  protocol          = "tcp"
  to_port           = 22
}

resource "aws_security_group_rule" "allow_ping_ipv4" {
  security_group_id = aws_security_group.ise-security-group.id
  type              = "ingress"
  cidr_blocks       = ["${var.zer0k_inside_subnet}", "${var.zer0k_vpn_subnet}", "${var.zer0k_entravpn_subnet}"]
  from_port         = -1
  protocol          = "icmp"
  to_port           = -1
}

resource "aws_security_group_rule" "allow_radiusold_ipv4" {
  security_group_id = aws_security_group.ise-security-group.id
  type              = "ingress"
  cidr_blocks       = ["${var.zer0k_inside_subnet}"]
  from_port         = 1645
  protocol          = "udp"
  to_port           = 1646
}

resource "aws_security_group_rule" "allow_radiusnew_ipv4" {
  security_group_id = aws_security_group.ise-security-group.id
  type              = "ingress"
  cidr_blocks       = ["${var.zer0k_inside_subnet}"]
  from_port         = 1812
  protocol          = "udp"
  to_port           = 1813
}

resource "aws_security_group_rule" "allow_ipv4_outbound" {
  security_group_id = aws_security_group.ise-security-group.id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = -1
  protocol          = "all"
  to_port           = -1
}

#Get AMI from Market Place for which ever region is being used
data "aws_ami" "ise-ami" {
    filter {
        name = "name"
        values = ["Cisco Identity Services Engine (ISE) v3.4*"]
    }
}

#Create a DNS Entry for the Node
resource "aws_route53_record" "www" {
  zone_id = "${var.zer0k_zoneid}"
  name    = "pod${var.pod_number}-ise1.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = ["10.${var.pod_number}.0.5"]
}

#Check if key pair exists before creating instance
data "aws_key_pair" "pod-keypair" {
  key_name = "pod${var.pod_number}-keypair"
}

output "pod-key-name" {
  value = "Creating Instance with Key Name: ${data.aws_key_pair.pod-keypair.key_name}"
}

#Create the ISE Instance
resource "aws_instance" "ise-instance" {
    ami = data.aws_ami.ise-ami.id
    instance_type = "${var.ise_instance_type}"
    private_ip = "10.${var.pod_number}.0.5"
    subnet_id = aws_subnet.pod-private-subnet.id
    key_name = data.aws_key_pair.pod-keypair.key_name
    vpc_security_group_ids =[aws_security_group.ise-security-group.id]
    
    ebs_block_device {
      device_name           = "/dev/sda1"
      delete_on_termination = true
      volume_type           = "gp3"
      volume_size           = 600
      encrypted             = false
    }

    user_data = base64encode(templatefile("userdata.tftpl", { hostname = "pod${var.pod_number}-ise1", dns_domain = var.domain_name, username = var.ise_username, password = var.ise_password, time_zone = var.ise_timezone, ers_api = var.ise_ersapi, open_api = var.ise_openapi, px_grid = var.ise_pxgrid, px_grid_cloud = var.ise_pxgridcloud, primarynameserver = local.dns_server_ip, ntpserver = local.ntp_server_ip}))
    
    tags = {
        Name = "pod${var.pod_number}-ise1"
        Created = "${local.formatted_date}"
    }
}

#Output Useful Information from the Deployment of the Resources
output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.ise-instance.id
}

output "instance_private_ip" {
  description = "The private IP address of the ISE instance"
  value       = aws_instance.ise-instance.private_ip
}

output "pod_number" {
  description = "The pod number"
  value       = "${var.pod_number}"
}

output "ise_password" {
  description = "Initial ISE Password"
  value       = "${var.ise_password}"
}