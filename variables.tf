variable "bucket_name" {
  description = "Bucket Name"
  default = "flugel-test1-bucket"
}
variable "alb_sg_name" {
  description = "Application load balancer security group name"
  default = "flugel-alb-sg-1"
}
variable "instance_sg_name" {
  description = "Instance security group name"
  default = "flugel-instance-sg-1"
}
variable "alb_name" {
  description = "Application load balancer name"
  default = "flugel-alb-1"
}
variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 80
}
variable "ec2_image_id" {
  description = "instance image id"
  # default     = "ami-0323c3dd2da7fb37d" amz linux 2
  default     = "ami-00043ff468d078003" # ecs with docker
}
variable "instance_type" {
  description = "instance image id"
  default     = "t2.nano"
}
variable "region" {
  description = "AWS Region"
  default     = "us-east-1"
}
variable "ssh_key" {
  description = "SSH key name"
  default     = "aws-ec2-servers"
}

locals {
  env_vars = {
    lb_host   = "${aws_lb.alb.dns_name}"
    region    = "${var.region}"
    bucket    = "${var.bucket_name}"
  }
}