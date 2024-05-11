
output "cloudfront_url" {
  value = aws_cloudfront_distribution.distribution.domain_name
}

output "s3_bucket_properties" {
  value = aws_s3_bucket.bucket.id
  }

output "aws_route53_zone" {
  value = data.aws_route53_zone.zone.id
}