#Get AMI from Market Place for which ever region is being used
data "aws_ami" "ise-ami" {
    filter {
        name = "name"
        values = ["Cisco Identity Services Engine (ISE) v3.4*"]
    }
}

#Set the DNS IP for the Selected VPC
locals {
  # Calculate the DNS server IP as the base address of the VPC's CIDR block plus 2
  dns_server_ip = cidrhost(aws_vpc.pod-vpc.cidr_block, 2)
  ntp_server_ip = "169.254.169.123"
}

#Create a DNS Entry for the Node
resource "aws_route53_record" "www" {
  zone_id = "${var.zer0k_zoneid}"
  name    = "pod${var.pod_number}-ise1.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = ["10.${var.pod_number}.0.5"]
}

#Create the ISE Instance
resource "aws_instance" "ise-instance" {
    ami = data.aws_ami.ise-ami.id
    instance_type = "${var.ise_instance_type}"
    private_ip = "10.${var.pod_number}.0.5"
    subnet_id = aws_subnet.pod-private-subnet.id
    key_name = "${var.pod_keypair}"
    vpc_security_group_ids =[aws_security_group.ise-security-group.id]
    user_data = "hostname=pod${var.pod_number}-ise1\nprimarynameserver=${local.dns_server_ip}\ndnsdomain=${var.domain_name}\nntpserver=${local.ntp_server_ip}\ntimezone=${var.ise_timezone}\nusername=${var.ise_username}\npassword=${var.ise_password}"

    tags = {
        Name = "pod${var.pod_number}-ise1"
        Created = "${local.formatted_date}"
    }
}