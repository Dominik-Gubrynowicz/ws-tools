variable "region" {
  type        = string
  description = "Aws region"
}
variable "cluster_name" {
  type        = string
  description = "Elasticache cluster name"
}
variable "vpc_id" {
  type        = string
  description = "VPC ID"
}
variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs to be used"
}