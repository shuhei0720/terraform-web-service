##########################################################
#　　ALBの作成
##########################################################

# web-service ALB

resource "aws_lb" "web-service-prod-alb" {
  name = "web-service-prod-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.web-service-prod-alb-securitygroup.id
  ]
  subnets = [
    aws_subnet.web-service-prod-alb-a-subnet.id,
    aws_subnet.web-service-prod-alb-c-subnet.id
  ]
  tags = {
    Name = "web-service-prod-alb",
    Project = "web-service",
    Env = "prod"
  }
  access_logs {
    bucket = aws_s3_bucket.web-service-prod-alb-access-log-276229188355.id
    enabled = true
  }
}

##########################################################
#　　ターゲットグループの作成
##########################################################

# EC2インスタンスweb-a用のターゲットグループ 443→80
# ターゲットグループ名は32文字以内にする必要がある

resource "aws_lb_target_group" "web-service-prod-web-a-80-tg" {
  name = "web-service-prod-web-a-80-tg"
  # ALBからEC2へトラフィックを振り分ける設定
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.vpc.id
  # EC2インスタンスを指定する
  target_type = "instance"
  slow_start = 0

  # webサーバへの死活監視（ヘルスチェック)設定
  # Health Checkのmatcherは301も入れる。(HTTPリダイレクトのため)
  health_check {
    protocol = "HTTP"
    path = "/index.html"
    port = 80
    healthy_threshold = 5
    unhealthy_threshold = 2
    timeout = 5
    interval = 30
    matcher = "200,301"
  }
  
  # ALB構築後にターゲットグループを割り当てる
  depends_on = [
    aws_lb.web-service-prod-alb
  ]
  tags = {
    Name = "web-service-prod-web-a-80-tg",
    Project = "web-service",
    NewRelicEnv = "prod"
  }
}

# EC2インスタンスweb-b用のターゲットグループ 443→80
# ターゲットグループ名は32文字以内にする必要がある

resource "aws_lb_target_group" "web-service-prod-web-b-80-tg" {
  name = "web-service-prod-web-b-80-tg"
  # ALBからEC2へトラフィックを振り分ける設定
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.vpc.id
  # EC2インスタンスを指定する
  target_type = "instance"
  slow_start = 0

  # webサーバへの死活監視(ヘルスチェック)設定
  # Health Checkのmasterは301も入れる。(HTTPリダイレクトのため)
  health_check {
    protocol = "HTTP"
    path = "/web-b/index.html"
    port = 80
    healthy_threshold = 5
    unhealthy_threshold = 2
    timeout = 5
    interval = 30
    matcher = "200,301"
  }

  # ALB構築後にターゲットグループに割り当てる
  depends_on = [
    aws_lb.web-service-prod-alb
  ]
  tags = {
    Name = "web-service-prod-web-b-80-tg",
    Project = "web-service",
    NewRelicEnv = "prod"
  }
}

######################################################################
#　ターゲットグループへターゲット(EC2インスタンス)登録
######################################################################

# web-service-prod-web-a-80-tgへweb-aを登録

resource "aws_lb_target_group_attachment" "web-service-prod-web-a-80-tg-attachment" {
  target_group_arn = aws_lb_target_group.web-service-prod-web-a-80-tg.arn
  target_id = aws_instance.web-service-prod-web-a.id
}

# web-service-prod-web-b-80-tgへweb-b登録

resource "aws_lb_target_group_attachment" "web-service-prod-web-b-80-tg-attachment" {
  target_group_arn = aws_lb_target_group.web-service-prod-web-b-80-tg.arn
  target_id = aws_instance.web-service-prod-web-b.id
}

#################################
#　　リスナーの作成
#################################

# 80→443(HTTPリダイレクト)

resource "aws_alb_listener" "web-service-prod-alb-http-to-https-redirect-listener" {
  load_balancer_arn = aws_lb.web-service-prod-alb.arn
  port = "80"
  protocol = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }
  tags = {
    Name = "web-service-prod-alb-http-to-https-redirect-listener",
    Project = "web-service",
    Env = "prod"
  }
}


# web-service用リスナー 443→80(HTTPS)

resource "aws_alb_listener" "web-service-prod-alb-443-listener" {
  load_balancer_arn = aws_lb.web-service-prod-alb.arn
  port = "443"
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  # ACM証明書をHTTPSリスナーに関連付け
  certificate_arn = aws_acm_certificate.shuhei-click.arn

  # デフォルトではweb-aに転送
  default_action {
    target_group_arn = aws_lb_target_group.web-service-prod-web-a-80-tg.arn
    type = "forward"
  }
  tags = {
    Name = "web-service-prod-alb-443-listener",
    Project = "web-service",
    Env = "prod"
  }
} 

######################################################################
#　　リスナールールの作成
######################################################################

# リスナールール1
# https://shuhei.click/web-bへのアクセスがあった場合は
# ターゲットグループweb-service-prod-web-b-80-tg(web-b所属)へ転送

resource "aws_lb_listener_rule" "web-service-prod-alb-443-listener-rule-01" {
  listener_arn = aws_alb_listener.web-service-prod-alb-443-listener.arn
  # 優先順位
  priority = 1
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.web-service-prod-web-b-80-tg.arn
  }
  condition {
    path_pattern {
      values = [
        "/web-b",
        "/web-b/*"
      ]
    }
  }
}
