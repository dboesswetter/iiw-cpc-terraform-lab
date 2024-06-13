resource "aws_launch_template" "myTemplate" {
  name_prefix   = "template-for-launch"
  image_id      = data.aws_ssm_parameter.al2023.value
  instance_type = var.instance_type
  key_name      = "vockey"
  user_data     = base64encode(file("userdata.sh"))
  vpc_security_group_ids = [aws_security_group.instance.id]
}

resource "aws_autoscaling_group" "myAutoscaler" {
  name                      = "autoscaler-pascalwende"
  max_size                  = 5
  min_size                  = 2
  health_check_grace_period = 300
  desired_capacity          = 4
  availability_zones        = [ "us-east-1a" ]
  force_delete              = true
  target_group_arns         = [aws_lb_target_group.default.arn]

  launch_template {
    id      = aws_launch_template.myTemplate.id
    version = "$Latest"
  }
  load_balancers = [aws_lb.default.name]
}
