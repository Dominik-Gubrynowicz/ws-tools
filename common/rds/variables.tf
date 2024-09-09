variable "region" {
  type        = string
  description = "Aws region"
}
variable "instance_name" {
  type        = string
  description = "Name of the instance"
}
variable "instance_type" {
  type        = string
  description = "Instance type"
}
variable "vpc_id" {
  type        = string
  description = "Vpc id"
}
variable "subnet_ids" {
  type        = list(string)
  description = "Subnet id"
}
variable "engine" {
  type        = string
  description = "Engine"
  default     = "aurora-postgresql"
}
variable "use_cmk" {
  type = bool
  description = "(optional) specifies whether to use kms encryption"
}
variable "username" {
  type = string
  description = "(optional) username"
}
variable "password" {
  type = string
  description = "(optional) password"
}
variable "engine_version" {
  type        = string
  description = "Engine version"
  default     = "5.7"
}
variable "default_database_name" {
  type        = string
  description = "Default database name"
}