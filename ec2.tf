# get the latest Amazon Linux 2023 AMI ID from parameter store
# (see https://docs.aws.amazon.com/linux/al2023/ug/ec2.html#launch-via-aws-cli)
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "default" {
  count         = var.instance_count
  instance_type = var.instance_type
  ami           = data.aws_ssm_parameter.al2023.value
  key_name      = "vockey"
  tags = {
    Name = "webserver-${terraform.workspace}-${count.index + 1}"
  }
  user_data                   = file("userdata.sh")
  user_data_replace_on_change = true
  vpc_security_group_ids      = [aws_security_group.instance.id]
  subnet_id                   = data.aws_subnets.default.ids[count.index]
}

data "aws_vpc" "default" {
  default = true
}

# security group for instances
resource "aws_security_group" "instance" {
  name   = "webserver-${terraform.workspace}"
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
  description       = "allow all outbound traffic (${terraform.workspace})"
}

# allow incoming SSH from anywhere
resource "aws_security_group_rule" "ssh" {
  security_group_id = aws_security_group.instance.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "allow SSH connections from anywhere (${terraform.workspace})"
}

# allow the loadbalancer HTTP access to instances
resource "aws_security_group_rule" "http" {
  security_group_id        = aws_security_group.instance.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = var.http_port
  to_port                  = var.http_port
  source_security_group_id = aws_security_group.alb.id
  description              = "allow HTTP from ALB (${terraform.workspace})"
}