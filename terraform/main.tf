provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "blog" {
  bucket = var.bucket_name

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  tags = {
    Name = "BlogBucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "blog" {
  bucket = aws_s3_bucket.blog.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "blog" {
  bucket = aws_s3_bucket.blog.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.blog.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.blog.arn}/*"
      }
    ]
  })
}

resource "aws_cloudfront_origin_access_identity" "blog" {
  comment = "CloudFront access identity for S3 bucket"
}

resource "aws_cloudfront_distribution" "blog" {
  origin {
    domain_name = aws_s3_bucket.blog.bucket_regional_domain_name
    origin_id   = "s3-blog"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.blog.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    target_origin_id       = "s3-blog"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  price_class = "PriceClass_100"

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "BlogDistribution"
  }
}

