#####################################
#　セキュリティグループの作成
#####################################

# web-a用セキュリティグループ

resource "aws_security_group" "web-service-prod-web-a-securitygroup" {
  name = "web-service-prod-web-a-securitygroup"
  description = "From web-service-prod-alb"
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "web-service-prod-web-a-securitygroup",
    Project = "web-service",
    Env = "prod"
  }
}

# web-b用セキュリティグループ

resource "aws_security_group" "web-service-prod-web-b-securitygourp" {
  name = "web-service-prod-web-b-securitygroup"
  description = "From web-service-prod-alb"
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "web-service-prod-web-b-securitygroup",
    Project = "web-service",
    Env = "prod"
  }
}
