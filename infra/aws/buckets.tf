locals {
  build_dir           = "${path.module}/dist"
  ingress_package_zip = "ingress_package.zip"
}

resource "random_pet" "lambda_bucket_name" {
  prefix = "ingress-package-lambda"
  length = 4
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = random_pet.lambda_bucket_name.id
}

resource "aws_s3_bucket_ownership_controls" "lambda_bucket" {
  bucket = aws_s3_bucket.lambda_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "lambda_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.lambda_bucket]

  bucket = aws_s3_bucket.lambda_bucket.id
  acl    = "private"
}

data "archive_file" "lambda_ingress_package" {
  type = "zip"

  source_dir  = "${path.module}/../../packages/ingress/dist"
  output_path = "${local.build_dir}/${local.ingress_package_zip}"
}


resource "aws_s3_object" "lambda_ingress_package" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = local.ingress_package_zip
  source = data.archive_file.lambda_ingress_package.output_path

  etag = filemd5(data.archive_file.lambda_ingress_package.output_path)
}
