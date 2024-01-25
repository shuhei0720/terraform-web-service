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
