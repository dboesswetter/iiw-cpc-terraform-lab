# get the latest Amazon Linux 2023 AMI ID from parameter store
# (see https://docs.aws.amazon.com/linux/al2023/ug/ec2.html#launch-via-aws-cli)
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "default" {
  count         = var.instance_count
  instance_type = "t3.micro"
  ami           = data.aws_ssm_parameter.al2023.value
  key_name      = "vockey"
  tags = {
    Name = "webserver${count.index + 1}"
  }
  user_data                   = <<EOF
#!/bin/bash

yum install -y nginx
systemctl enable nginx
systemctl start nginx
EOF
  user_data_replace_on_change = true
  vpc_security_group_ids      = [aws_security_group.instance.id]
}

data "aws_vpc" "default" {
  default = true
}

# security group for instances
resource "aws_security_group" "instance" {
  name   = "webserver"
  vpc_id = data.aws_vpc.default.id
}

# allow all outbound traffic
resource "aws_security_group_rule" "egress" {
  security_group_id = aws_security_group.instance.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "allow all outbound traffic"
}

# allow incoming SSH from anywhere
resource "aws_security_group_rule" "ssh" {
  security_group_id = aws_security_group.instance.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "allow SSH connections from anywhere"
}

# allow the loadbalancer HTTP access to instances
resource "aws_security_group_rule" "http" {
  security_group_id        = aws_security_group.instance.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 80
  to_port                  = 80
  source_security_group_id = aws_security_group.alb.id
  description              = "allow HTTP from ALB"
}