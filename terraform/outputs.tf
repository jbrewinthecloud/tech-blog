output "s3_bucket_name" {
  description = "The name of the blog S3 bucket"
  value       = aws_s3_bucket.blog.bucket
}

output "cloudfront_domain_name" {
  description = "CloudFront Distribution domain name"
  value       = aws_cloudfront_distribution.blog.domain_name
}

