###
# All AWS S3 related stuff
##

resource "aws_s3_bucket" "blog" {
  bucket = "jcast.dev"

  lifecycle {
    prevent_destroy = true
  }

  provider = aws.eu-west-1
}

resource "aws_s3_bucket_public_access_block" "blog" {
  bucket                  = aws_s3_bucket.blog.id
  block_public_acls       = true  # Keep blocking ACLs
  block_public_policy     = false # Allow bucket policy to control access
  ignore_public_acls      = true
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "blog" {
  bucket = aws_s3_bucket.blog.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = "*",
      Action    = "s3:GetObject",
      Resource  = "${aws_s3_bucket.blog.arn}/*"
    }]
  })
}

### Adding www bucket
resource "aws_s3_bucket" "www_redirect" {
  bucket   = "www.jcast.dev"
  provider = aws.eu-west-1
}

resource "aws_s3_bucket_website_configuration" "www_redirect" {
  bucket = aws_s3_bucket.www_redirect.id

  redirect_all_requests_to {
    host_name = "jcast.dev"
    protocol  = "https"
  }
}