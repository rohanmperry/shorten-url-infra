output "acm_certificate_validation_cname" {
  description = "Add this CNAME to Namecheap to validate the ACM certificate"
  value       = aws_acm_certificate.short_url.domain_validation_options
}

output "custom_domain_target" {
  description = "Add this as CNAME target for short.manamperi.com in Namecheap"
  value       = aws_apigatewayv2_domain_name.short_url.domain_name_configuration[0].target_domain_name
}

output "acm_certificate_arn" {
  description = "ACM certificate ARN for CloudFront"
  value       = aws_acm_certificate_validation.short_url.certificate_arn
}
