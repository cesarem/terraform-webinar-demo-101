output "load_balancer_fqdn" {
  value = module.kt_test.lb_dns_name
}

output "instance_dns" {
  value = aws_instance.example.public_dns
}

output "url_file1" {
  value = "http://${module.kt_test.lb_dns_name}/test1.txt"
}

output "url_file2" {
  value = "http://${module.kt_test.lb_dns_name}/test2.txt"
}

output "lb_url" {
  value = "http://${module.kt_test.lb_dns_name}"
}

output "file_timestamp" {
    value = module.kt_test.timestamp
}