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
