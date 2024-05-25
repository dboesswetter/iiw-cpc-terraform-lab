resource "aws_launch_template" "myTemplate" {
  name_prefix   = "myTemplate"
  image_id      = "ami-1a2b3c"
  instance_type = "t2.micro"
}

resource "aws_autoscaling_group" "myAutoscaler" {
  name                      = "autoscaler-pascalwende"
  max_size                  = 5
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 4
  force_delete              = true

  launch_template {
    id      = aws_launch_template.myTemplate.id
    version = "$Latest"
  }

  load_balancers = [aws_lb.default.name]
  
}
