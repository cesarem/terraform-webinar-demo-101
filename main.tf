provider "aws" {
  version = "~> 2.63"
  region  = var.region
}

# Instance Image ID
data "aws_ami" "image_id" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["devops-crew-image_id"]
  }
}

#########################################
# Generate random pets for resource names
#########################################
resource "random_pet" "server" {
  keepers = {
    name = var.name
  }
}

###########
# S3 bucket
###########
resource "aws_s3_bucket" "main" {
  bucket = "${random_pet.server.id}-devops-crew-bucket"
  acl    = "private"

  tags = {
    Name = "devops crew demo bucket"
  }
}

############
# S3 Objects
############
resource "aws_s3_bucket_object" "object_1" {
  bucket  = aws_s3_bucket.main.id
  key     = "test1.txt"
  content = timestamp()
}
resource "aws_s3_bucket_object" "object_2" {
  bucket  = aws_s3_bucket.main.id
  key     = "test2.txt"
  content = timestamp()
}

#####
# VPC
#####
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "DevOps Crew VPC"
  }
}

###################
# Internet Gateways
###################
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "DevOps Crew Internet GW"
  }
}

##############
# Route Tables
##############
resource "aws_route_table" "inet" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "DevOps Crew Internet Route Table"
  }
}
resource "aws_route_table" "nat" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw.id
  }
  
  tags = {
    Name = "DevOps Crew NAT Route Table"
  }

}

# Route table association (to Internet)
resource "aws_route_table_association" "pub_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.inet.id
}

# Route table association NAT
resource "aws_route_table_association" "nat_assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.nat.id
}

##################
# Launch templates
##################
resource "aws_launch_template" "public_cluster" {
  name_prefix   = "${random_pet.server.id}-public-cluster"
  image_id      = data.aws_ami.image_id.id
  instance_type = var.instance_type
  key_name      = var.ssh_key

  iam_instance_profile {
    name = aws_iam_instance_profile.s3_access.name
  }

  user_data = base64encode(data.template_file.init.rendered)

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.public_sg.id]
    delete_on_termination       = true
  }

  tags = {
    Name = "Public Cluster"
  }
}

resource "aws_launch_template" "private_cluster" {
  name_prefix   = "${random_pet.server.id}-private-cluster"
  image_id      = data.aws_ami.image_id.id
  instance_type = var.instance_type
  key_name      = var.ssh_key

  iam_instance_profile {
    name = aws_iam_instance_profile.s3_access.name
  }

  user_data = base64encode(data.template_file.init.rendered)

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.private_sg.id]
    delete_on_termination       = true
  }

  tags = {
    Name = "DevOps Crew Private Cluster"
  }
}

#####################
# Auto scaling groups
#####################
resource "aws_autoscaling_group" "public_asg" {
  vpc_zone_identifier       = [aws_subnet.public.id]
  target_group_arns         = [aws_lb_target_group.asg.arn]
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 1
  max_size                  = 1
  min_size                  = 1

  launch_template {
    id      = aws_launch_template.public_cluster.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "devops crew public asg"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "private_asg" {
  vpc_zone_identifier       = [aws_subnet.private.id]
  target_group_arns         = [aws_lb_target_group.asg.arn]
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 1
  max_size                  = 1
  min_size                  = 1

  launch_template {
    id      = aws_launch_template.private_cluster.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "devops crew private asg"
    propagate_at_launch = true
  }
}

#################
# Security Groups
#################
resource "aws_security_group" "alb_sg" {
  name   = "${random_pet.server.id}-alb-sg"
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "allow_http"
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

resource "aws_security_group" "public_sg" {
  name   = "${random_pet.server.id}-public-sg-1"
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "public sg traffic"
  }
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private_sg" {
  name   = "${random_pet.server.id}-private-sg-1"
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "private sg traffic"
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#########
# Subnets
#########
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.region}b"

  tags = {
    Name = "private subnet"
  }

  timeouts {
    create = "10m"
    delete = "5m"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name = "public subnet"
  }

  timeouts {
    create = "10m"
    delete = "5m"
  }
}

################
# Load Balancers
################
resource "aws_lb" "alb" {
  name               = "${random_pet.server.id}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public.id, aws_subnet.private.id]

  tags = {
    Name = "DevOps Crew Application Load Balancer"
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
  name     = aws_lb.alb.name
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

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
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}

#############
# Elastic IPs
#############
resource "aws_eip" "natgw" {
  vpc        = true
  depends_on = [aws_internet_gateway.gw]

  tags = {
    Name = "EIP nat gw"
  }

}

##############
# NAT Gateways
##############
resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.natgw.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "gw NAT"
  }
}

###################
# Instance Profiles
###################
resource "aws_iam_instance_profile" "s3_access" {
  name = "s3_access_profile"
  role = aws_iam_role.ec2_trusted_entity_to_s3.name
}

###########
# IAM Roles
###########
resource "aws_iam_role" "ec2_trusted_entity_to_s3" {
  name               = "ec2_trusted_entity_to_s3"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}
###################
# Policy attachment
###################
resource "aws_iam_role_policy_attachment" "s3_read_only_policy" {
  role       = aws_iam_role.ec2_trusted_entity_to_s3.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

############
# IAM Policy
############
resource "aws_iam_policy" "s3_policy" {
  name        = "devops-s3-policy"
  description = "Especific policy to get acces to bucket ${aws_s3_bucket.main.id}"
  policy      = data.aws_iam_policy_document.s3_access_policy.json
}

data "template_file" "init" {
  template = file("${path.module}/init.tpl")
  vars = {
    lb_host = aws_lb.alb.dns_name
    region  = var.region
    bucket  = aws_s3_bucket.main.id
  }
}

# Bucket policy data source
data "aws_iam_policy_document" "s3_access_policy" {
  statement {
    sid = "1"

    effect = "Allow"

    actions = [
      "s3:Get*",
      "s3:List*"
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.main.id}",
      "arn:aws:s3:::${aws_s3_bucket.main.id}/*"
    ]
  }
}

# Asume role policy data source
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    sid = ""

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}