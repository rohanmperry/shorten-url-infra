provider "aws" {
  region = var.aws_region
}

resource "aws_acm_certificate" "short_url" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = var.domain_name
    Environment = var.environment
  }
}

resource "aws_acm_certificate_validation" "short_url" {
  certificate_arn = aws_acm_certificate.short_url.arn
}
