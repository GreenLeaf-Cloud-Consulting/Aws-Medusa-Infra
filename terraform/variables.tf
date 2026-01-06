variable "aws_access_key" {
  description = "AWS Access Key"
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
  sensitive   = true
}

variable "region" {
  description = "AWS Region"
  default     = "eu-west-3"
}

variable "environment" {
  description = "Deployment Environment"
  default     = "dev"
}

variable "ssh_user" {
  description = "User to connect via SSH"
  type        = string
  default     = "admin"
}