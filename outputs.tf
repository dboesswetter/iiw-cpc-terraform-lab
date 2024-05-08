output "ec2_instance_public_dns_names" {
  value = aws_instance.default.*.public_dns
}

output "alb_public_dns_names" {
  value = aws_lb.default.dns_name
}
