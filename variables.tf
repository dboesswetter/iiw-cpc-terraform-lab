variable "instance_count" {
  type        = string
  description = "Number of EC2 instances to launch"
  default     = 1
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type to use for webservers"
  default     = "t2.micro"
}

variable "http_port" {
  type        = number
  description = "default http port"
  default     = 80
}
variable "ami_id" {
  description = "The AMI ID to use for the instances."
  type        = string
}

variable "subnet_ids" {
  description = "The subnet IDs to launch the instances in."
  type        = list(string)
}