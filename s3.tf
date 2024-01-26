####################################
# ALB Access Log用S3バケットの作成
####################################

resource "aws_s3_bucket" "web-service-prod-alb-access-log-276229188355" {
  bucket = "web-service-prod-alb-access-log-276229188355"
  force_destroy = false
  tags = {
    Name = "web-service-prod-alb-access-log-276229188355",
    Project = "web-service",
    Env = "prod"
  }
}

###################################
#　S３バケットのACLの設定
###################################

# S3バケットのオブジェクト所有者(ACL設定)

resource "aws_s3_bucket_ownership_controls" "web-service-prod-alb-access-log-276229188355-bucket-acl-owner" {
  bucket = aws_s3_bucket.web-service-prod-alb-access-log-276229188355.id
  rule { object_ownership = "BucketOwnerEnforced" }
}

###################################
#　パブリックアクセスブロック
###################################

resource "aws_s3_bucket_public_access_block" "web-service-prod-alb-access-log-276229188355-public-access-block" {
  bucket = aws_s3_bucket.web-service-prod-alb-access-log-276229188355.id
  # ブロックパブリックアクセスを有効にする
  block_public_acls = true # S3バケットのパブリックACLをブロックするかどうか
  block_public_policy = true # S3バケットのパブリックバケットポリシーをブロックするかどうか
  ignore_public_acls = true # S3バケットのパブリックACLを無視するかどうか
  restrict_public_buckets = true # S3バケットのパブリックバケットポリシーを制限するかどうか
}

###################################
#　ライフサイクルルールの定義
###################################

# 180日経過したファイルは削除

resource "aws_s3_bucket_lifecycle_configuration" "web-service-prod-alb-access-log-276229188355-lifecycle-configuration" {
  bucket = aws_s3_bucket.web-service-prod-alb-access-log-276229188355.id
  rule {
    status = "Enabled"
    id = "default"
    expiration {
      days = "180"
    }
  }
}

##################################
#　ポリシードキュメントの作成
##################################

# ALBなどのAWSサービスからS3へのアクセス権を定義

data "aws_iam_policy_document" "web-service-prod-alb-access-log-276229188355-policy-document" {
  statement {
    effect = "Allow"
    actions = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.web-service-prod-alb-access-log-276229188355.id}/*"]
    # 識別子(identifiers)はロードバランサーのリージョンに対応するAWSアカウントIDを指定
    principals {
      type = "AWS"
      identifiers = ["582318560864"]
    }
  }
}

#################################
#　　ポリシーの作成
#################################

# ポリシーを作成してバケットに割り当てる

resource "aws_s3_bucket_policy" "web-service-prod-alb-access-log-276229188355-bucket-policy" {
  bucket = aws_s3_bucket.web-service-prod-alb-access-log-276229188355.id
  policy = data.aws_iam_policy_document.web-service-prod-alb-access-log-276229188355-policy-document.json
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
