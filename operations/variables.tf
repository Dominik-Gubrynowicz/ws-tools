variable "region" {
    type = string
    description = "AWS region"
}
variable "vpc_id" {
  type = string
  description = "VPC ID"
}
variable "subnet_id" {
  type = string
  description = "Subnet ID"
}
variable "s3_vpce_id" {
    type = string
    description = "Id of VPCE"
}
variable "role_name" {
    type = string
    default = null
    description = "Optional instance role arn"
}