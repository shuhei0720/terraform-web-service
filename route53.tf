#########################################################
#　　Route53 ゾーンの作成
#########################################################

# ドメイン shuhei.clickの検証用data

data "aws_route53_zone" "shuhei-click" {
  name = "shuhei.click"
  private_zone = false
}

# shuhei.clickドメイン検証

resource "aws_route53_record" "shuhei-click" {
  for_each = {
    for dvo in aws_acm_certificate.shuhei-click.domain_validation_options : dvo.domain_name => {
      name = dvo.resource_record_name
      record = dvo.resource_record_value
      type = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name = each.value.name
  records = [each.value.record]
  ttl = 60
  type = each.value.type
  zone_id = data.aws_route53_zone.shuhei-click.zone_id
}
