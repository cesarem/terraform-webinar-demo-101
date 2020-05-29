variable "bucket_name" {
  description = "Bucket Name"
  default     = "flugel-test1-bucket"
}
variable "alb_sg_name" {
  description = "Application load balancer security group name"
  default     = "flugel-alb-sg-1"
}
variable "instance_sg_name" {
  description = "Instance security group name"
  default     = "flugel-instance-sg-1"
}
variable "alb_name" {
  description = "Application load balancer name"
  default     = "flugel-alb-1"
}
variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default     = 80
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