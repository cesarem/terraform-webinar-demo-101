provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}

# S3 bucket
resource "aws_s3_bucket" "flugel" {
  bucket = "${var.bucket_name}"
  acl    = "private"

  tags = {
    Name        = "Flugel Test"
    Environment = "Dev"
  }
}
# S3 Objects
resource "aws_s3_bucket_object" "object_1" {
  bucket = "${aws_s3_bucket.flugel.id}"
  key    = "test1.txt"
        content = "${timestamp()}"
}
resource "aws_s3_bucket_object" "object_2" {
  bucket = "${aws_s3_bucket.flugel.id}"
  key    = "test2.txt"
        content = "${timestamp()}"
}

## VPC
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  
  tags = {
    Name = "Flugel VPC"
  }
}
# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "Flugel Internet GW"
  }
}

# Route to Internet
resource "aws_route_table" "inet" {
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
  tags = {
    Name = "Flugel Internet Route Table"
  }
}
# Route table association (to Internet)
resource "aws_route_table_association" "pub_assoc" {
  subnet_id      = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.inet.id}"
}
resource "aws_route_table_association" "priv_assoc" {
  subnet_id      = "${aws_subnet.private.id}"
  route_table_id = "${aws_route_table.inet.id}"
}

## EC2 Instances
resource "aws_launch_configuration" "cluster" {
  image_id        = "ami-07ebfd5b3428b6f4d"
  instance_type   = "t2.micro"
  key_name        = "aws-ec2-servers"
  associate_public_ip_address = true
  security_groups = [aws_security_group.instance_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF

  # Required when using a launch configuration with an auto scaling group.
  # https://www.terraform.io/docs/providers/aws/r/launch_configuration.html
  lifecycle {
    create_before_destroy = true
  }
}
# Auto scaling group
resource "aws_autoscaling_group" "cluster" {
  launch_configuration = "${aws_launch_configuration.cluster.name}"
  vpc_zone_identifier  = ["${aws_subnet.public.id}", "${aws_subnet.private.id}"]

  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  min_size = 2
  max_size = 2

  tag {
    key                 = "Name"
    value               = "flugel-asg-terraform"
    propagate_at_launch = true
  }
}

## Security Groups
# application load balancer sg
resource "aws_security_group" "alb_sg" {
  name          = "${var.alb_sg_name}"
  vpc_id        = "${aws_vpc.main.id}"
  tags = {
    Name = "flugel_allow_http"
  }
  # Allow inbound HTTP requests
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow all outbound requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# instance security_group
resource "aws_security_group" "instance_sg" {
  name          = "${var.instance_sg_name}"
  vpc_id        = "${aws_vpc.main.id}"
  tags = {
    Name = "flugel_instance_web_traffic"
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

## Subnets
# Private subnet
resource "aws_subnet" "private" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Flugel private subnet"
  }
}
# Public subnet
resource "aws_subnet" "public" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "Flugel public subnet"
  }
}

## Application load balancer
# alb
resource "aws_lb" "alb" {
  name               = "${var.alb_name}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.alb_sg.id}"]
  subnets            = ["${aws_subnet.public.id}", "${aws_subnet.private.id}"]
  
  tags = {
    Name = "Flugel ALB"
  }
}
# HTTP listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}
# Target group
resource "aws_lb_target_group" "asg" {
  name      = aws_lb.alb.name
  port      = var.server_port
  protocol  = "HTTP"
  vpc_id    = "${aws_vpc.main.id}"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}
# Listener rule
resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    field  = "path-pattern"
    values = ["*"]
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}