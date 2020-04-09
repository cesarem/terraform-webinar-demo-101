variable "bucket_name" {
  default = "flugel-test1-bucket"
}
variable "alb_sg_name" {
  default = "flugel-alb-sg-1"
}
variable "instance_sg_name" {
  default = "flugel-instance-sg-1"
}
variable "alb_name" {
  default = "flugel-alb-1"
}
variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 80
}