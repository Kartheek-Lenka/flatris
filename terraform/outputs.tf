output "s3_bucket_name" {
  description = "S3 bucket where game files are stored"
  value       = aws_s3_bucket.flatris.bucket
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID (used for cache invalidation)"
  value       = aws_cloudfront_distribution.flatris.id
}

output "cloudfront_url" {
  description = "Public URL to play the Flatris game"
  value       = "https://${aws_cloudfront_distribution.flatris.domain_name}"
}
