####################################
#　　　VPCの作成
####################################

# プロジェクト　web-service用 VPC

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "web-service-prod-vpc",
    Project = "web-service",
    Env = "prod"
  }
}

####################################
#　　　サブネットの作成
####################################

# ALB用サブネット　アベイラビリティゾーンA

resource "aws_subnet" "web-service-prod-alb-a-subnet" {
  vpc_id = aws_vpc.vpc.id
  availability_zone = "ap-northeast-1a"
  cidr_block = "10.0.100.0/24"
  tags = {
    Name = "web-service-prod-alb-a-subnet",
    Project = "web-service",
    Env = "prod"
  }
}

#ALB用サブネット　アベイラビリティゾーンC

resource "aws_subnet" "web-service-prod-alb-c-subnet" {
  vpc_id = aws_vpc.vpc.id
  availability_zone = "ap-northeast-1c"
  cidr_block = "10.0.101.0/24"
  tags = {
    Name = "web-service-prod-alb-c-subnet",
    Project = "web-service",
    Env = "prod"
  }
}

#EC2用サブネット　アベイラビリティゾーンA

resource "aws_subnet" "web-service-prod-ec2-a-subnet" {
  vpc_id = aws_vpc.vpc.id
  availability_zone = "ap-northeast-1a"
  cidr_block = "10.0.102.0/24"
  tags = {
    Name = "web-service-prod-ec2-a-subnet",
    Project = "web-server",
    Env = "prod"
  }
}

####################################
#　インターネットゲートウェイの作成
####################################

# ALB用インターネットゲートウェイ

resource "aws_internet_gateway" "web-service-prod-internetgateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "web-service-prod-internetgateway",
    Project = "web-service",
    Env = "prod"
  }
}

####################################
#　　NATゲートウェイの作成
####################################

# NATゲートウェイ用にEIPを1つ取得する

resource "aws_eip" "web-service-prod-natgateway-eip" {
  # warningが出たため、domain = "vpc" に修正
  # vpc = true
  domain = "vpc"
  tags = {
    Name = "web-service-prod-natgateway-eip",
    Project = "web-service",
    Env = "prod"
  }
}

# EC2インスタンス用にNATゲートウェイを作成する

resource "aws_nat_gateway" "web-service-prod-natgateway" {
  # NAT Gatewayを配置するサブネット(web-service-prod-alb-a-subnet)を指定する
  subnet_id = aws_subnet.web-service-prod-alb-a-subnet.id
  # NAT Gatewayに紐づけるEIP
  allocation_id = aws_eip.web-service-prod-natgateway-eip.id
  tags = {
    Name = "web-service-prod-natgateway",
    Project = "web-service",
    Env = "prod"
  }
}

#####################################
# 　ルートテーブルの作成
#####################################

# ALB用パブリックサブネット　アベイラビリティゾーンA用ルートテーブル

resource "aws_route_table" "web-service-prod-alb-a-subnet-routetable" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "web-service-prod-alb-a-subnet-routetable",
    Project = "web-service",
    Env = "prod"
  }
}

# ALB用パブリックサブネット　アベイラビリティゾーンC用ルートテーブル

resource "aws_route_table" "web-service-prod-alb-c-subnet-routetable" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "web-service-prod-alb-c-subnet-routetable",
    Project = "web-service",
    Env = "prod"
  }
}

# EC2用プライベートサブネット　アベイラビリティゾーンA用ルートテーブル

resource "aws_route_table" "web-service-prod-ec2-a-subnet-routetable" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "web-service-prod-ec2-a-subnet-routetable",
    Project = "web-service",
    Env = "prod"
  }
}

######################################
# 　　ルートの作成
######################################

# ALB用パブリックサブネット　アベイラビリティゾーンA用ルートテーブル用ルート01

resource "aws_route" "web-service-prod-alb-a-subnet-route-01" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id = aws_route_table.web-service-prod-alb-a-subnet-routetable.id
  gateway_id = aws_internet_gateway.web-service-prod-internetgateway.id
}

# ALB用パブリックサブネット　アベイラビリティゾーンC用ルートテーブル用ルート01

resource "aws_route" "web-service-prod-alb-c-subnet-route-01" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id = aws_route_table.web-service-prod-alb-c-subnet-routetable.id
  gateway_id = aws_internet_gateway.web-service-prod-internetgateway.id
}

# EC2用プライベートサブネット　アベイラビリティゾーンA用ルートテーブル用ルート01

resource "aws_route" "web-service-prod-ec2-a-subnet-route-01" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id = aws_route_table.web-service-prod-ec2-a-subnet-routetable.id
  nat_gateway_id = aws_nat_gateway.web-service-prod-natgateway.id
}

######################################
#　サブネットとルートテーブルの紐づけ
######################################

# web-service-prod-alb-a-subnetとweb-service-prod-a-subnet-routetableの紐づけ

resource "aws_route_table_association" "web-service-prod-alb-a-subnet-routetable-association-01" {
  subnet_id = aws_subnet.web-service-prod-alb-a-subnet.id
  route_table_id = aws_route_table.web-service-prod-alb-a-subnet-routetable.id
}

# web-service-prod-alb-c-subnetとweb-service-prod-c-subnet-routetableの紐づけ

resource "aws_route_table_association" "web-service-prod-alb-c-subnet-routetable-association-01" {
  subnet_id = aws_subnet.web-service-prod-alb-c-subnet.id
  route_table_id = aws_route_table.web-service-prod-alb-c-subnet-routetable.id
}

# web-service-prod-ec2-a-subnetとweb-service-prod-ec2-a-subnet-routetableの紐づけ

resource "aws_route_table_association" "web-service-prod-ec2-a-subnet-routetable-association-01" {
  subnet_id = aws_subnet.web-service-prod-ec2-a-subnet.id
  route_table_id = aws_route_table.web-service-prod-ec2-a-subnet-routetable.id
}
