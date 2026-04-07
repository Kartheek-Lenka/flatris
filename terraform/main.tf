# ──────────────────────────────────────────
# S3 Bucket (Private - for static hosting via CloudFront)
# ──────────────────────────────────────────
resource "aws_s3_bucket" "flatris" {
  bucket        = var.bucket_name
  force_destroy = true

  tags = {
    Name        = "Flatris Game"
    Environment = var.environment
  }
}

# Enable versioning (good practice)
resource "aws_s3_bucket_versioning" "flatris" {
  bucket = aws_s3_bucket.flatris.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Block all public access (security best practice)
resource "aws_s3_bucket_public_access_block" "flatris" {
  bucket = aws_s3_bucket.flatris.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ──────────────────────────────────────────
# CloudFront Origin Access Control (OAC)
# ──────────────────────────────────────────
resource "aws_cloudfront_origin_access_control" "flatris" {
  name                              = "flatris-oac"
  description                       = "OAC for Flatris S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# ──────────────────────────────────────────
# CloudFront Distribution (CDN + HTTPS)
# ──────────────────────────────────────────
resource "aws_cloudfront_distribution" "flatris" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  comment             = "Flatris Game CDN"

  origin {
    domain_name              = aws_s3_bucket.flatris.bucket_regional_domain_name
    origin_id                = "flatrisS3Origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.flatris.id
  }

  default_cache_behavior {
    target_origin_id       = "flatrisS3Origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    compress = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600  # 1 hour
    max_ttl     = 86400 # 24 hours
  }

  # SPA Routing Fix (important for React apps)
  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Free HTTPS via CloudFront
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  # Ensure S3 bucket exists before CloudFront
  depends_on = [
    aws_s3_bucket.flatris
  ]

  tags = {
    Name        = "Flatris CDN"
    Environment = var.environment
  }
}

# ──────────────────────────────────────────
# S3 Bucket Policy (Allow ONLY CloudFront OAC)
# ──────────────────────────────────────────
resource "aws_s3_bucket_policy" "flatris" {
  bucket = aws_s3_bucket.flatris.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontAccess"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.flatris.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.flatris.arn
          }
        }
      }
    ]
  })

  depends_on = [
    aws_cloudfront_distribution.flatris
  ]
}
