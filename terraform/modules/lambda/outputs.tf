output "create_short_url_function_name" {
  description = "Name of the create_short_url Lambda function"
  value       = aws_lambda_function.create_short_url.function_name
}

output "create_short_url_function_arn" {
  description = "ARN of the create_short_url Lambda function"
  value       = aws_lambda_function.create_short_url.arn
}

output "redirect_function_name" {
  description = "Name of the redirect Lambda function"
  value       = aws_lambda_function.redirect.function_name
}

output "redirect_function_arn" {
  description = "ARN of the redirect Lambda function"
  value       = aws_lambda_function.redirect.arn
}

output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = aws_dynamodb_table.urls.name
}

output "dynamodb_table_arn" {
  description = "DynamoDB table ARN"
  value       = aws_dynamodb_table.urls.arn
}

output "lambda_security_group_id" {
  description = "Security group ID for Lambda functions"
  value       = aws_security_group.lambda.id
}

output "lambda_role_arn" {
  description = "IAM role ARN for Lambda functions"
  value       = aws_iam_role.lambda.arn
}
