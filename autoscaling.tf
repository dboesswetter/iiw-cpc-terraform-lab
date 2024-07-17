resource "aws_launch_template" "app" {
  name_prefix   = "app-launch-template-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  user_data     = filebase64("userdata.sh")

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "app" {
  desired_capacity     = var.instance_count
  max_size             = var.instance_count
  min_size             = var.instance_count
  vpc_zone_identifier  = var.subnet_ids
  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }
  target_group_arns = [aws_lb_target_group.default.arn]

  tag {
    key                 = "Name"
    value               = "my-app-instance"
    propagate_at_launch = true
  }
}
