output "acm_certificate_validation_cname" {
  description = "Add this CNAME to Namecheap to validate the ACM certificate"
  value       = aws_acm_certificate.short_url.domain_validation_options
}

output "acm_certificate_arn" {
  description = "ACM certificate ARN for CloudFront"
  value       = aws_acm_certificate_validation.short_url.certificate_arn
}
