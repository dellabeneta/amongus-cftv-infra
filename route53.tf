data "aws_route53_zone" "zone" {
  name         = "dellabeneta.tech"
  private_zone = false
}

resource "aws_route53_record" "amongus" {
  zone_id = data.aws_route53_zone.zone.id
  name    = "amongus"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.distribution.domain_name
    zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
    evaluate_target_health = false
  }
}