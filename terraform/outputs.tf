output "s3_bucket_name" {
  value = aws_s3_bucket.flatris.bucket
}

output "cloudfront_distribution_id" {
  value = "N/A"
}

output "cloudfront_url" {
  value = "http://${aws_s3_bucket.flatris.bucket}.s3-website-${var.aws_region}.amazonaws.com"
}
