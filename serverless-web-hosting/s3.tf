resource "aws_s3_bucket" "main" {
  bucket = "s3-web-hosting-chori"

  tags = {
    Name = "s3-web-hosting-chori"
  }
}

resource "aws_s3_bucket_website_configuration" "web_hosting" {
  bucket = aws_s3_bucket.main.id

  index_document {
    suffix = "mycar.html"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public_read_policy" {
  bucket = aws_s3_bucket.main.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.main.arn}/*"
      }
    ]
  })
}