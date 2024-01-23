############################################
#　セキュリティグループの作成
############################################

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
