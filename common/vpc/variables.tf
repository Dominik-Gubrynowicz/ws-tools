variable "vpc_id" {
  type        = string
  description = "The VPC ID"
}
variable "region" {
  type        = string
  description = "The AWS region"
}
variable "azs_number" {
  type        = number
  default     = 2
  description = "(optional) describe your variable"
}
variable "public_subnets" {
  type        = bool
  description = "Create public subnet"
}
variable "private_subnets" {
  type = list(object({
    name     = string
    internet = bool
  }))
  description = "Create X private subnets"
}
variable "gateway_endpoints" {
  type        = bool
  description = "Create gw endpoints"
}
variable "igw" {
  type        = string
  description = "Create IGW, or pass existing id"
}
variable "custom_cidr" {
  type        = string
  default     = ""
  description = "Custom cidr range to be used for subnetting"
}