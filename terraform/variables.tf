variable "aws_region" {
  description = "AWS region"
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name tag"
  default     = "flatris"
}

variable "key_pair_name" {
  description = "Name of your AWS EC2 key pair for SSH access"
  type        = string
}
