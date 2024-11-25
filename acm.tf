data "aws_acm_certificate" "wildcard" {
  provider = aws.us-east-1  # Certificados para CloudFront devem estar em us-east-1
  domain   = "*.dellabeneta.tech"
  statuses = ["ISSUED"]
}
