# ──────────────────────────────────────────
# S3 Bucket (Static Website Hosting)
# ──────────────────────────────────────────
resource "aws_s3_bucket" "flatris" {
  bucket        = var.bucket_name
  force_destroy = true

  tags = {
    Name        = "Flatris Game"
    Environment = var.environment
  }
}

# Enable versioning
resource "aws_s3_bucket_versioning" "flatris" {
  bucket = aws_s3_bucket.flatris.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Allow public access (needed for website hosting)
resource "aws_s3_bucket_public_access_block" "flatris" {
  bucket = aws_s3_bucket.flatris.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Website configuration
resource "aws_s3_bucket_website_configuration" "flatris" {
  bucket = aws_s3_bucket.flatris.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# Public read policy
resource "aws_s3_bucket_policy" "flatris" {
  bucket = aws_s3_bucket.flatris.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource  = "${aws_s3_bucket.flatris.arn}/*"
      }
    ]
  })
}
