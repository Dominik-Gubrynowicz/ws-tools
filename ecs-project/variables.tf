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
variable "max_container_number" {
  type        = number
  description = "Max number of instances in ASG"
}
variable "max_instance_number" {
  type = number
  description = "Max instance number"
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
variable "task_role" {
  type = string
  default = null
  description = "ECS task role"
}
variable "execution_task_role" {
  type = string
  default = null
  description = "execution ECS task role"
}
variable "ec2_role_name" {
  type        = string
  default     = null
  description = "Optional instance role arn"
}
variable "ec2_arch" {
  type = string
  description = "ec2 arch"
  default = "x86_64"
}
variable "image_url" {
  type = string
  description = "Image url"
}
variable "app_cpu" {
  type = number
  description = "container CPU"
}
variable "app_memory" {
  type = number
  description = "container memory"
}