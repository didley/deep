locals {
  bootstrap_file_path = "${path.module}/utils/bootstrap/bootstrap.zip"
}

resource "aws_lambda_function" "ingress_lambda" {
  function_name = "ingress_lambda"
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  role          = aws_iam_role.lambda_exec.arn
  filename      = local.bootstrap_file_path

  lifecycle {
    # Prevent Terraform from touching deployment after initial resource creation. Deployment is done within package dir.
    ignore_changes = [source_code_hash]
  }
}

resource "aws_cloudwatch_log_group" "ingress_lambda" {
  name              = "/aws/lambda/${aws_lambda_function.ingress_lambda.function_name}"
  retention_in_days = 30
}
