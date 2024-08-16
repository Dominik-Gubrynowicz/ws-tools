variable "region" {
  type        = string
  description = "Aws region"
}
variable "dynamodb_name" {
  type        = string
  description = "Name of dynamodb table"
}
variable "dynamodb_primary_key" {
  type        = string
  description = "Name of a primary key"
}
variable "dynamodb_sort_key" {
  type        = string
  default     = null
  description = "Name of primary key"
}