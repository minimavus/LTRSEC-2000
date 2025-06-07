#Student Set Variables
variable "pod_number" {
        description = "Assigned Pod Number"
        type = string
        default = "<TBD>"
}
variable "pod_keypair" {
        description = "Key Pair Created By the Student"
        type = string
        default = "<TBD>"
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
variable "zer0k_entravpn_subnet" {
        description = "Zer0k Entra VPN Subnet CIDR"
        type = string
        default = "172.16.2.0/24"
}
variable "zer0k_zoneid" {
        description = "zer0k Route53 DNS Zone ID"
        type = string
        default = "Z03312021O7TSH12BOWDW"
}

#ISE Variables
variable "ise_instance_type" {
        description = "ISE AMI Instance Type"
        type = string
        default = "m5.4xlarge"
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
variable "ise_ersapi" {
        description = "Enable ERS API by Default?"
        type = string
        default = "yes"
}
variable "ise_openapi" {
        description = "Enable Open API by Default?"
        type = string
        default = "yes"
}
variable "ise_pxgrid" {
        description = "Enable PxGrid by Default?"
        type = string
        default = "no"
}
variable "ise_pxgridcloud" {
        description = "Enable PxGrid Cloud by Default?"
        type = string
        default = "no"
}
