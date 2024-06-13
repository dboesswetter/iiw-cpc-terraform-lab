variable "instance_count" {
  type        = string
  description = "Number of EC2 instances to launch"
  default     = 5
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type to use for webservers"
  default     = "t2.micro"
}

variable "http_port" {
  type = string
  description = "HTTP Port"
  default = 80
}