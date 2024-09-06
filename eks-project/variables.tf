variable "region" {
  type = string
  description = "AWS region name"
}
variable "vpc_id" {
  type = string
  description = "VPC id"
}
variable "app_subnet_ids" {
  type = list(string)
  description = "App subnet ids"
}
variable "instance_types" {
  type = list(string)
  description = "Instance types"
}
variable "max_instance_number" {
  type = string
  description = "Max instance number"
}