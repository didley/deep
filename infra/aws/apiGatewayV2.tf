resource "aws_apigatewayv2_api" "http_api" {
  name          = "api"
  protocol_type = "HTTP"
  version       = "0.0.0"
}

resource "aws_cloudwatch_log_group" "http_api" {
  name              = "/aws/apigw2/${aws_apigatewayv2_api.http_api.name}"
  retention_in_days = 30
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.http_api.arn
    format          = "$context.requestId $context.httpMethod $context.path $context.status"
  }
}

resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ingress_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

resource "aws_apigatewayv2_integration" "lambda_proxy" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.ingress_lambda.invoke_arn
}

resource "aws_apigatewayv2_route" "get_ingress_lambda" {
  api_id = aws_apigatewayv2_api.http_api.id
  # Catch all route, routing is bing handled within the lambda.
  route_key = "ANY /ingress/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_proxy.id}"
}
