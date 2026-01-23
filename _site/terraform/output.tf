output "bucket_name" {
  description = "The name of the bucket where you can host your static website"
  value       = aws_s3_bucket.blog.bucket
}

output "cloudfront_distribution_arn" {
  description = "The ARN of the Cloudfront distribution"
  value       = aws_cloudfront_distribution.cf_distribution.arn
}
