locals {
  build_dir           = "${path.module}/dist"
  ingress_package_zip = "ingress_package.zip"
  bucket_name         = "ingress-package-lambda"
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = local.bucket_name
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
