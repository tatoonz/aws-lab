variable "region" {
  description = "AWS region for all resources."
  type        = string
  default     = "ap-southeast-7"
}

variable "aws_profile" {
  description = "AWS profile to use for authentication."
  type = string
}

variable "name_prefix" {
  description = "Prefix to use for creating unique resource names"
  type        = string
}
