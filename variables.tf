variable "region" {
  description = "AWS region for DevOps Demo"
  default     = "us-east-1"
}

variable "name" {
  description = "Name to be used on all the resources as identifier"
  type = string
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default     = 80
}

variable "instance_type" {
  description = "instance image id"
  default     = "t2.micro"
}

variable "ssh_key" {
  description = "SSH key name"
  default     = "aws-ec2-servers"
}