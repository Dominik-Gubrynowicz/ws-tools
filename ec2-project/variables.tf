variable "region" {
  type        = string
  description = "AWS region"
}
variable "app_name" {
  type        = string
  description = "App name"
}
variable "instance_type" {
  type        = string
  description = "Instance type"
}
variable "app_port" {
  type        = number
  description = "Application port"
}
variable "expose_port" {
  type        = number
  description = "Expose port"
}
variable "ami_id" {
  type        = string
  description = "AMI id to be used"
}
variable "max_number" {
  type        = number
  description = "Max number of instances in ASG"
}
variable "health_check_path" {
  type        = string
  description = "Health check path"
}
variable "vpc_id" {
  type        = string
  description = "VPC ID"
}
variable "alb_subnet_ids" {
  type        = list(string)
  description = "ALB Subnet IDs"
}
variable "app_subnet_ids" {
  type        = list(string)
  description = "Subnet IDs"
}
variable "role_name" {
  type        = string
  default     = null
  description = "Optional instance role arn"
}