variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
}

variable "create_short_url_function_arn" {
  description = "ARN of the create_short_url Lambda function"
  type        = string
}

variable "create_short_url_function_name" {
  description = "Name of the create_short_url Lambda function"
  type        = string
}

variable "redirect_function_arn" {
  description = "ARN of the redirect Lambda function"
  type        = string
}

variable "redirect_function_name" {
  description = "Name of the redirect Lambda function"
  type        = string
}
