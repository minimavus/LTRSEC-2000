#Reference AWS Access Kyes defined in terraform.tfvars
variable "aws_access_key" {
}
variable "aws_secret_key" {
}

#Student Set Variables
variable "pod_number" {
        description = "Assigned Pod Number"
        type = string
        default = "0"
}