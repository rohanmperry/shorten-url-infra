resource "aws_apigatewayv2_api_mapping" "short_url" {
  api_id      = module.api_gateway.api_id
  domain_name = "short.manamperi.com"
  stage       = "$default"
}
