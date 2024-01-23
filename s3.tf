####################################
#ALB Access Log用S3バケットの作成
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
