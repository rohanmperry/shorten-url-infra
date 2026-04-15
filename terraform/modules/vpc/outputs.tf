output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.main.id
}

output "nat_gateway_id" {
  description = "NAT Gateway ID (empty if not enabled)"
  value       = var.enable_nat_gateway ? aws_nat_gateway.main[0].id : null
}

output "private_route_table_id" {
  description = "Private route table ID — used by VPC endpoints"
  value       = aws_route_table.private.id
}

output "dynamodb_vpc_endpoint_id" {
  description = "VPC Gateway Endpoint ID for DynamoDB"
  value       = aws_vpc_endpoint.dynamodb.id
}
