variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

variable "bucket_name" {
  description = "S3 bucket name for the Flatris game"
  type        = string
  default     = "flatris-game-karthik"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"
}
