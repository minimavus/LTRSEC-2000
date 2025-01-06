#Student Set Variables
variable "pod_number" {
        description = "Assigned Pod Number"
        type = string
        default = "0"
}
variable "pod_keypair" {
        description = "Key Pair Created By the Student"
        type = string
        default = "zer0k-mgmt"
}

#Reference AWS Access Kyes defined in terraform.tfvars
variable "aws_access_key" {
}
variable "aws_secret_key" {
}

#Lab Environment Variables
variable "zer0k_transit_gateway" {
        description = "Transit Gateway ID"
        type = string
        default = "tgw-00ecf6a9a26ff37cf"
}
variable "zer0k_private_subnet" {
        description = "Zer0k Private Subnet CIDR"
        type = string
        default = "172.18.16.0/21"
}
variable "zer0k_inside_subnet" {
        description = "Zer0k Inside Subnet CIDR"
        type = string
        default = "172.18.24.0/21"
}
variable "zer0k_vpn_subnet" {
        description = "Zer0k VPN Subnet CIDR"
        type = string
        default = "172.16.1.0/24"
}

#ISE Variables
variable "ise_instance_type" {
        description = "ISE AMI Instance Type"
        type = string
        default = "c5.9xlarge"
}
variable "domain_name" {
        description = "Domain Name"
        type = string
        default = "zer0k.org"
}
variable "ise_username" {
        description = "ISE Default Username"
        type = string
        default = "iseadmin"
}
variable "ise_password" {
}
variable "ise_timezone" {
        description = "Default ISE Timezone"
        type = string
        default = "UTC"
}