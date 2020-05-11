output "lb_dns_name" {
  value = aws_lb.alb.dns_name
}
output "timestamp" {
  value = aws_s3_bucket_object.object_2.content
}