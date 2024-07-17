# application load balancer
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_lb" "default" {
  name               = "webserver-${terraform.workspace}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = data.aws_subnets.default.ids
    access_logs {
    bucket  = aws_s3_bucket.alb_logs.bucket
    prefix  = "my-alb-logs"
    enabled = true
  }
  
  enable_deletion_protection = false
  enable_cross_zone_load_balancing = true

  tags = {
    Name = "webserver-prod-alb"
  }
}


resource "aws_security_group" "alb" {
  name   = "alb-${terraform.workspace}-sg"
  vpc_id = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  protocol          = "tcp"
  type              = "ingress"
  from_port         = var.http_port
  to_port           = var.http_port
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "allow HTTP (${terraform.workspace})"
}

resource "aws_security_group_rule" "alb_egress" {
  security_group_id = aws_security_group.alb.id
  protocol          = "tcp"
  type              = "egress"
  from_port         = var.http_port
  to_port           = var.http_port
  cidr_blocks       = [data.aws_vpc.default.cidr_block]
  description       = "allow outbound HTTP (${terraform.workspace})"
}

# HTTP listener
resource "aws_lb_listener" "default" {
  load_balancer_arn = aws_lb.default.arn
  port              = var.http_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default.arn
  }
}


# target group with our instances
resource "aws_lb_target_group" "default" {
  name     = "webserver-${terraform.workspace}-tg"
  port     = var.http_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
}

resource "aws_lb_target_group_attachment" "test" {
  count            = var.instance_count
  target_group_arn = aws_lb_target_group.default.arn
  target_id        = aws_instance.default[count.index].id
  port             = var.http_port
}
