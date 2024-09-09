variable "region" {
  type        = string
  description = "Aws region"
}
variable "repository_name" {
  type        = string
  description = "Name of ECR repo"
}
variable "use_cmk" {
  type = bool
  description = "(optional) specifies whether to use kms encryption"
}