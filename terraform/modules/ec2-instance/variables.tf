variable "allowed_ports" {
  description = "List of allowed ports for the security group"
  type    = list(number)
  default     = [22, 80, 443]
}

variable "region" {
  description = "The AWS region where resources will be created"
  type        = string
}

variable "ami" {
  description = "The AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "The instance type for the EC2 instance"
  type        = string
}

variable "environment" {
  description = "The deployment environment"
  type        = string
}

variable "instance_name" {
  description = "The name of the instance"
  type        = string
}

variable "ansible_playbook" {
  description = "The Ansible playbook to use for provisioning"
  type        = string
  default     = "playbook.yml"
}

variable "backend_ip" {
  description = "Backend IP address for frontend instances"
  type        = string
  default     = ""
}

variable "frontend_ip" {
  description = "Frontend IP address for backend CORS configuration"
  type        = string
  default     = ""
}

variable "use_elastic_ip" {
  description = "Whether to allocate an Elastic IP for this instance"
  type        = bool
  default     = false
}