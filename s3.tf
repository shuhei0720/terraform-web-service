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
