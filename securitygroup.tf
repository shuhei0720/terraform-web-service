############################################
#　セキュリティグループの作成
############################################

# ALB用セキュリティグループ

resource "aws_security_group" "web-service-prod-alb-securitygroup" {
  name = "web-service-prod-alb-securitygroup"
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "web-service-prod-alb-securitygroup",
    Project = "web-service",
    Env = "prod"
  }
}

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

resource "aws_security_group" "web-service-prod-web-b-securitygroup" {
  name = "web-service-prod-web-b-securitygroup"
  description = "From web-service-prod-alb"
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "web-service-prod-web-b-securitygroup",
    Project = "web-service",
    Env = "prod"
  }
}

############################################
#　セキュリティグループのルールの作成
############################################

# ALB用セキュリティグループのインバウンドルール 01
# 443/TCPで受け付ける

resource "aws_security_group_rule" "web-service-prod-alb-securitygroup-ingress-rule01" {
  description = "From Internet with 443"
  from_port = "443"
  to_port = "443"
  protocol = "tcp"
  type = "ingress"
  #  tfsec:ignore:aws-ec2-no-public-ingress-sgr
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web-service-prod-alb-securitygroup.id
}

# ALB用セキュリティグループのインバウンドルール 02
# 80/TCPで受け付けて443/TCPにリダイレクトする

resource "aws_security_group_rule" "web-service-prod-alb-securitygroup-ingress-rule02" {
  description = "From Internet with 80"
  from_port = "80"
  to_port = "80"
  protocol = "tcp"
  type = "ingress"
  # checkov:skip=CKV_AWS_260:80 port from internet skip
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web-service-prod-alb-securitygroup.id
}

# ALB用セキュリティグループのアウトバウンドルール 01

resource "aws_security_group_rule" "web-service-prod-alb-securitygroup-egress-rule01" {
  from_port = 0
  to_port = 0
  protocol = "-1"
  type = "egress"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web-service-prod-alb-securitygroup.id
}

# web-a用セキュリティグループのインバウンドルール 01
# ALBから80/TCPでリッスンする

resource "aws_security_group_rule" "web-service-prod-web-a-securitygroup-ingress-rule-01" {
  description = "From web-service-prod-alb"
  from_port = "80"
  to_port = "80"
  protocol = "tcp"
  type = "ingress"
  cidr_blocks = ["10.0.100.0/24"]
  security_group_id = aws_security_group.web-service-prod-web-a-securitygroup.id
}

# web-a用セキュリティグループのインバウンドルール 02
# ALBから80/TCPでリッスンする

resource "aws_security_group_rule" "web-service-prod-web-a-securitygroup-ingress-rule-02" {
  description = "From web-service-prod-alb"
  from_port = "80"
  to_port = "80"
  protocol = "tcp"
  type = "ingress"
  cidr_blocks = ["10.0.101.0/24"]
  security_group_id = aws_security_group.web-service-prod-web-a-securitygroup.id
}

# web-a用セキュリティグループのアウトバウンドルール 01

resource "aws_security_group_rule" "web-service-prod-web-a-securitygroup-egress-rule-01" {
  from_port = 0
  to_port = 0
  protocol = "-1"
  type = "egress"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web-service-prod-web-a-securitygroup.id
}

# web-b用セキュリティグループのインバウンドルール 01
# ALBから80/TCPでリッスンする

resource "aws_security_group_rule" "web-service-prod-web-b-securitygroup-ingress-rule-01" {
  description = "From web-service-prod-alb"
  from_port = "80"
  to_port = "80"
  protocol = "tcp"
  type = "ingress"
  cidr_blocks = ["10.0.100.0/24"]
  security_group_id = aws_security_group.web-service-prod-web-b-securitygroup.id
}

# web-b用セキュリティグループのインバウンドルール 02
# ALBから80/TCPでリッスンする

resource "aws_security_group_rule" "web-service-prod-web-b-securitygroup-ingress-rule-02" {
  description = "From web-service-prod-alb"
  from_port = "80"
  to_port = "80"
  protocol = "tcp"
  type = "ingress"
  cidr_blocks = ["10.0.101.0/24"]
  security_group_id = aws_security_group.web-service-prod-web-b-securitygroup.id
}

# web-b用セキュリティグループのアウトバウンドルール 01

resource "aws_security_group_rule" "web-service-prod-web-b-securitygroup-egress-rule-01" {
  from_port = 0
  to_port = 0
  protocol = "-1"
  type = "egress"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web-service-prod-web-b-securitygroup.id
}
