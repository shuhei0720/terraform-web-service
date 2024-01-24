######################################################
#　　ACM SSL証明書の作成
######################################################

# web-service-prod-alb用のACM SSL/TLS証明書
# ドメイン shuhei.click

resource "aws_acm_certificate" "shuhei-click" {
  domain_name = "shuhei.click"
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = "shuhei.click"
    Project = "web-service"
    Env = "prod"
  }
}

# ドメイン shuhei.clickの検証

resource "aws_acm_certificate_validation" "shuhei-click" {
  certificate_arn = aws_acm_certificate.shuhei-click.arn
  validation_record_fqdns = [for record in aws_route53_record.shuhei-click : record.fqdn]
}
