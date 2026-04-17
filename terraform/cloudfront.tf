resource "aws_cloudfront_origin_access_control" "frontend" {
  name                              = "shorten-url-frontend-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "short_url" {
  enabled             = true
  default_root_object = "index.html"
  aliases             = ["short.manamperi.com"]
  price_class         = "PriceClass_100"

  custom_error_response {
    error_code            = 404
    response_code         = 404
    response_page_path    = "/404.html"
    error_caching_min_ttl = 10
  }

  origin {
    origin_id                = "s3-frontend"
    domain_name              = data.terraform_remote_state.app.outputs.frontend_bucket_regional_domain
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend.id
  }

  origin {
    origin_id = "api-gateway"
    # Remove the 'https://' from front and '/' from end of the api_endpoint string.
    domain_name = trimsuffix(trimprefix(module.api_gateway.api_endpoint, "https://"), "/")
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # If none of the 'ordered_cache_behavior' patterns match,
  # use this. The 'ordered_cache_behavior' patterns match in
  # order, os the order is important.
  #
  default_cache_behavior {
    target_origin_id       = "s3-frontend"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }
    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  # This is redundant, because '/' does not match any of the
  # follong patterns and goes to default above. Kept for
  # clarity.
  # ordered_cache_behavior {
  #   path_pattern           = "/"
  #   target_origin_id       = "s3-frontend"
  #   viewer_protocol_policy = "redirect-to-https"
  #   allowed_methods        = ["GET", "HEAD"]
  #   cached_methods         = ["GET", "HEAD"]
  #   forwarded_values {
  #     query_string = false
  #     cookies { forward = "none" }
  #   }
  #   min_ttl     = 0
  #   default_ttl = 3600
  #   max_ttl     = 86400
  # }

  ordered_cache_behavior {
    path_pattern           = "/index.html"
    target_origin_id       = "s3-frontend"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }
    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  # POST /shorten is called by JavaScript fetch() in the browser, not directly
  # by the browser itself. Typing <domain>/shorten in the browser
  # sends a GET which API Gateway rejects — this is expected and not a bug.
  # curl POST <domain>/shorten will also work.
  #
  ordered_cache_behavior {
    path_pattern           = "/shorten"
    target_origin_id       = "api-gateway"
    viewer_protocol_policy = "redirect-to-https"

    # All required by CloudFront even if we need only POST and OPTIONS
    allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]

    # required by CloudFront even if never used
    cached_methods = ["GET", "HEAD"]

    forwarded_values {
      query_string = false # Uses JSON, not a string
      cookies { forward = "none" }
      # JavaScript in the browser (or curl) uses this (Content-Type: application/json)
      # in the POST request to the API GW. So the CF distrib. should pass it.
      headers = ["Content-Type"]
    }
    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0
  }

  ordered_cache_behavior {
    path_pattern           = "/*"
    target_origin_id       = "api-gateway"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    forwarded_values {
      query_string = true
      cookies { forward = "none" }
    }
    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0
  }

  viewer_certificate {
    acm_certificate_arn      = data.terraform_remote_state.manual.outputs.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction { restriction_type = "none" }
  }

  tags = {
    Name        = "shorten-url-cloudfront"
    Environment = var.environment
  }
}
