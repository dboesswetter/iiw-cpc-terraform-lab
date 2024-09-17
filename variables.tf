variable "instance_count" {
  type        = string
  description = "Number of EC2 instances to launch"
  default     = 1
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type to use for webservers"
  default     = "t3.micro"
}

variable "http_port" {
  type = number
  default = 80
}

variable "elb_account_id" {
  default = "127311923021"
}