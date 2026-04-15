output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "create_short_url_function_name" {
  description = "Name of the create_short_url Lambda function"
  value       = module.lambda.create_short_url_function_name
}

output "redirect_function_name" {
  description = "Name of the redirect Lambda function"
  value       = module.lambda.redirect_function_name
}

output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = module.lambda.dynamodb_table_name
}

output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = module.api_gateway.api_endpoint
}
