# ---- IAM Role for Lambda ----
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "lambda_dynamodb" {
  name = "${var.project_name}-lambda-dynamodb-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ]
        Resource = var.dynamodb_arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# ---- Lambda Packages ----
data "archive_file" "get_message_zip" {
  type        = "zip"
  source_dir  = "${path.root}/lambda/getMessage"
  output_path = "${path.root}/lambda/getMessage.zip"
}

data "archive_file" "post_message_zip" {
  type        = "zip"
  source_dir  = "${path.root}/lambda/postMessage"
  output_path = "${path.root}/lambda/postMessage.zip"
}

# ---- Lambda Functions ----
resource "aws_lambda_function" "get_message" {
  filename         = data.archive_file.get_message_zip.output_path
  source_code_hash = data.archive_file.get_message_zip.output_base64sha256
  function_name    = "${var.project_name}-getMessage"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  timeout          = 10

  environment {
    variables = {
      DYNAMODB_TABLE = var.dynamodb_table
      AWS_REGION_NAME = var.aws_region
    }
  }

  tags = merge(var.tags, { Name = "${var.project_name}-getMessage" })
}

resource "aws_lambda_function" "post_message" {
  filename         = data.archive_file.post_message_zip.output_path
  source_code_hash = data.archive_file.post_message_zip.output_base64sha256
  function_name    = "${var.project_name}-postMessage"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  timeout          = 10

  environment {
    variables = {
      DYNAMODB_TABLE = var.dynamodb_table
      AWS_REGION_NAME = var.aws_region
    }
  }

  tags = merge(var.tags, { Name = "${var.project_name}-postMessage" })
}


# ---- API Gateway ----
resource "aws_api_gateway_rest_api" "messages_api" {
  name        = "${var.project_name}-api"
  description = "Serverless Messages API"

  tags = var.tags
}

resource "aws_api_gateway_resource" "messages" {
  rest_api_id = aws_api_gateway_rest_api.messages_api.id
  parent_id   = aws_api_gateway_rest_api.messages_api.root_resource_id
  path_part   = "messages"
}

# ---- GET Method ----
resource "aws_api_gateway_method" "get_messages" {
  rest_api_id   = aws_api_gateway_rest_api.messages_api.id
  resource_id   = aws_api_gateway_resource.messages.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.messages_api.id
  resource_id             = aws_api_gateway_resource.messages.id
  http_method             = aws_api_gateway_method.get_messages.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_message.invoke_arn
}

# ---- POST Method ----
resource "aws_api_gateway_method" "post_message" {
  rest_api_id   = aws_api_gateway_rest_api.messages_api.id
  resource_id   = aws_api_gateway_resource.messages.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "post_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.messages_api.id
  resource_id             = aws_api_gateway_resource.messages.id
  http_method             = aws_api_gateway_method.post_message.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.post_message.invoke_arn
}

# ---- OPTIONS (CORS Preflight) ----
resource "aws_api_gateway_method" "options_messages" {
  rest_api_id   = aws_api_gateway_rest_api.messages_api.id
  resource_id   = aws_api_gateway_resource.messages.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_mock" {
  rest_api_id = aws_api_gateway_rest_api.messages_api.id
  resource_id = aws_api_gateway_resource.messages.id
  http_method = aws_api_gateway_method.options_messages.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_200" {
  rest_api_id = aws_api_gateway_rest_api.messages_api.id
  resource_id = aws_api_gateway_resource.messages.id
  http_method = aws_api_gateway_method.options_messages.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.messages_api.id
  resource_id = aws_api_gateway_resource.messages.id
  http_method = aws_api_gateway_method.options_messages.http_method
  status_code = aws_api_gateway_method_response.options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# ---- Lambda Permissions ----
resource "aws_lambda_permission" "get_api_gw" {
  statement_id  = "AllowAPIGatewayInvokeGet"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_message.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.messages_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "post_api_gw" {
  statement_id  = "AllowAPIGatewayInvokePost"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.post_message.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.messages_api.execution_arn}/*/*"
}

# ---- API Deployment ----
resource "aws_api_gateway_deployment" "messages_deployment" {
  rest_api_id = aws_api_gateway_rest_api.messages_api.id

  depends_on = [
    aws_api_gateway_integration.get_lambda,
    aws_api_gateway_integration.post_lambda,
    aws_api_gateway_integration.options_mock,
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.messages_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.messages_api.id
  stage_name    = var.environment

  tags = var.tags
}