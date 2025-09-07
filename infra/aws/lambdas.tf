resource "aws_s3_object" "seed" {
  bucket = local.bucket_name
  key    = local.ingress_package_zip
  source = "${path.module}/utils/bootstrap/bootstrap.zip"
  etag   = filemd5("${path.module}/utils/bootstrap/bootstrap.zip")
}

resource "aws_lambda_function" "ingress_lambda" {
  function_name = "IngressPackage"
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  role          = aws_iam_role.lambda_exec.arn

  # Only used on first create, Makefile handles deployment afterwards.
  s3_bucket = local.bucket_name
  s3_key    = aws_s3_object.seed.key

  lifecycle {
    # Prevent Terraform from touching deployment after initial resource creation.
    ignore_changes = [
      s3_bucket,
      s3_key,
      s3_object_version,
      source_code_hash,
    ]
  }
}

resource "aws_cloudwatch_log_group" "ingress_package" {
  name              = "/aws/lambda/${aws_lambda_function.ingress_lambda.function_name}"
  retention_in_days = 30
}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
