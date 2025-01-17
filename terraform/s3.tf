resource "aws_s3_bucket" "public_bucket" {
  bucket        = "${var.environment}${var.domain_name}"
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "public_bucket_website_config" {
  bucket = aws_s3_bucket.public_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  routing_rule {
    condition {
      http_error_code_returned_equals = 404
    }
    redirect {
      host_name = "www.meepleprofessionals.com"
      replace_key_prefix_with = "?x-not-found=/"
    }
  }

}

resource "aws_s3_bucket_acl" "public_bucket_acl" {
  bucket = aws_s3_bucket.public_bucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "public_bucket_policy" {
  bucket = aws_s3_bucket.public_bucket.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "PublicReadAllow",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${var.environment}${var.domain_name}/*"
    }
  ]
}
POLICY
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.public_bucket.bucket
  key          = "index.html"
  content      = templatefile("./public_webpage/index.tftpl", { lambda_url = "${aws_lambda_function_url.lambda_url.function_url}" })
  content_type = "text/html"
}