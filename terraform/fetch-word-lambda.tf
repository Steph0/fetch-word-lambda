terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }

    archive = {
      source = "hashicorp/archive"
    }
  }
}

provider "aws" {
  profile = var.profile
  region  = var.region
}

#################################################
#
# Packaging
# 
#################################################

# Creates a zip archive from source code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "../index.js"
  output_path = "${path.module}/target/lambda.zip"
}

#################################################
#
# Lambda function
# 
#################################################

# Creates a role giving right to execute Lambda
resource "aws_iam_role" "lambda_exec" {

  name_prefix        = "fetch-word"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Creates a Lambda function from zip archive and attached to exec role
resource "aws_lambda_function" "fetch_word" {
  function_name    = "fetch-word-lambda"
  handler          = "index.handler"
  runtime          = "nodejs12.x"
  role             = aws_iam_role.lambda_exec.arn
  filename         = "${path.module}/target/lambda.zip"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

# Gives permission for Lambda to be accessed by API Gateway
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.fetch_word.function_name
  principal     = "apigateway.amazonaws.com"
  # Use the "/*/*" portion to grant access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/${aws_api_gateway_method.method_get.http_method}/"
}

#################################################
#
# API gateway
# 
#################################################

# Creates a regional API
resource "aws_api_gateway_rest_api" "api" {
  name        = "fetch-word"
  description = "fetch-word-lambda API"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Sets an HTTP verb for that API
resource "aws_api_gateway_method" "method_get" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_rest_api.api.root_resource_id
  http_method   = "GET"
  authorization = "NONE"
}

# Attaches that API to the fetch-word Lambda
resource "aws_api_gateway_integration" "integration_lambda" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_method.method_get.resource_id
  http_method = aws_api_gateway_method.method_get.http_method
  # Must use POST as per Lambda invoke API
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.fetch_word.invoke_arn
}

# Creates PROD stage
resource "aws_api_gateway_deployment" "deployment_prod" {
  depends_on = [aws_api_gateway_integration.integration_lambda]

  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "prod"

  # Every API update must re-trigger a deployment as per AWS model instructions
  triggers = {
    redeployment = sha1(join(",", list(
      jsonencode(aws_api_gateway_integration.integration_lambda),
    )))
  }

  lifecycle {
    create_before_destroy = true
  }
}

output "fetch_word_base_url" {
  value = aws_api_gateway_deployment.deployment_prod.invoke_url
}