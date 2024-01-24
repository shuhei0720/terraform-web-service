##############################################
#　　EC2インスタンスの作成
##############################################

# web-aの作成

resource "aws_instance" "web-service-prod-web-a" {
  ami = "ami-03dceaabddff8067e"
  associate_public_ip_address = "false"
  instance_type = "t3a.nano"
  subnet_id = aws_subnet.web-service-prod-ec2-a-subnet.id
  vpc_security_group_ids = [aws_security_group.web-service-prod-web-a-securitygroup.id]
  user_data = <<-EOF
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;
echo "web-service-prod-web-a" > /var/www/html/index.html
EOF
  tags = {
    Name = "web-service-prod-web-a",
    Project = "web-service",
    NewRelicEnv = "prod"
  }
}

# web-bの作成

resource "aws_instance" "web-service-prod-web-b" {
  ami = "ami-03dceaabddff8067e"
  associate_public_ip_address = "false"
  instance_type = "t3a.nano"
  subnet_id = aws_subnet.web-service-prod-ec2-a-subnet.id
  vpc_security_group_ids = [aws_security_group.web-service-prod-web-b-securitygroup.id]
  user_data = <<-EOF
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
mkdir -p /var/www/html/web-b
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;
echo "web-service-prod-web-b" > /var/www/html/index.html
echo "web-b web-service-prod-web-b" > /var/www/html/web-b/index.html
EOF
  tags = {
    Name = "web-service-prod-web-b",
    Project = "web-service",
    NewRelicEnv = "prod"
  }
}
