locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# DynamoDB Table
resource "aws_dynamodb_table" "urls" {
  name         = "${local.name_prefix}-urls"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "short_code"

  attribute {
    name = "short_code"
    type = "S"
  }

  tags = {
    Name = "${local.name_prefix}-urls"
  }
}

# SSM Parameter — base URL
resource "aws_ssm_parameter" "base_url" {
  name  = "/${var.project_name}/${var.environment}/base_url"
  type  = "String"
  value = var.base_url

  tags = {
    Name = "${local.name_prefix}-base-url"
  }
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda" {
  name = "${local.name_prefix}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${local.name_prefix}-lambda-role"
  }
}

# IAM Policy — least privilege
# DynamoDB, SSM, CloudWatch, VPC networking
data "aws_iam_policy_document" "lambda" {
  statement {
    sid    = "DynamoDBAccess"
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Query",
      "dynamodb:Scan",
    ]
    resources = [aws_dynamodb_table.urls.arn]
  }

  statement {
    sid    = "SSMAccess"
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
    ]
    resources = [aws_ssm_parameter.base_url.arn]
  }

  statement {
    sid    = "CloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/aws/lambda/${local.name_prefix}-*"]
  }

  statement {
    sid    = "VPCNetworking"
    effect = "Allow"
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
    ]
    resources = ["*"]
  }

  statement {
    sid       = "ECRAuthToken"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid    = "ECRImagePull"
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
    ]
    resources = ["arn:aws:ecr:${var.aws_region}:${var.aws_account_id}:repository/shorten-url/*"]
  }
}

resource "aws_iam_policy" "lambda" {
  name        = "${local.name_prefix}-lambda-policy"
  description = "Least privilege policy for ${local.name_prefix} Lambda functions"
  policy      = data.aws_iam_policy_document.lambda.json
}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda.arn
}

# Security Group for Lambda
resource "aws_security_group" "lambda" {
  name        = "${local.name_prefix}-lambda-sg"
  description = "Security group for Lambda functions"
  vpc_id      = var.vpc_id

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-lambda-sg"
  }
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "create_short_url" {
  name              = "/aws/lambda/${local.name_prefix}-create-short-url"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${local.name_prefix}-create-short-url-logs"
  }
}

resource "aws_cloudwatch_log_group" "redirect" {
  name              = "/aws/lambda/${local.name_prefix}-redirect"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${local.name_prefix}-redirect-logs"
  }
}

# Get ECR image IDs
data "aws_ecr_image" "create_short_url" {
  repository_name = "shorten-url/create-short-url"
  image_tag       = "latest"
}
data "aws_ecr_image" "redirect" {
  repository_name = "shorten-url/redirect"
  image_tag       = "latest"
}

# Lambda Functions
resource "aws_lambda_function" "create_short_url" {
  function_name = "${local.name_prefix}-create-short-url"
  role          = aws_iam_role.lambda.arn
  package_type  = "Image"
  image_uri     = "${data.aws_ecr_image.create_short_url.registry_id}.dkr.ecr.${var.aws_region}.amazonaws.com/shorten-url/create-short-url@${data.aws_ecr_image.create_short_url.image_digest}"
  timeout       = 10
  memory_size   = 128

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.urls.name
      BASE_URL       = var.base_url
      ENVIRONMENT    = var.environment
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda,
    aws_cloudwatch_log_group.create_short_url
  ]

  tags = {
    Name = "${local.name_prefix}-create-short-url"
  }
}

resource "aws_lambda_function" "redirect" {
  function_name = "${local.name_prefix}-redirect"
  role          = aws_iam_role.lambda.arn
  package_type  = "Image"
  image_uri     = "${data.aws_ecr_image.redirect.registry_id}.dkr.ecr.${var.aws_region}.amazonaws.com/shorten-url/redirect@${data.aws_ecr_image.redirect.image_digest}"
  timeout       = 10
  memory_size   = 128

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.urls.name
      ENVIRONMENT    = var.environment
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda,
    aws_cloudwatch_log_group.redirect
  ]

  tags = {
    Name = "${local.name_prefix}-redirect"
  }
}
