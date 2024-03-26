provider "aws" {
  region = "us-east-1"
}

resource "aws_elb" "main" {
  name               = "main-load-balancer"
  availability_zones = ["us-east-1a", "us-east-1b"]

  listener {
    instance_port     = 80
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:80/"
  }
}

resource "aws_launch_configuration" "blue" {
  name_prefix   = "blue-"
  image_id      = "ami-12345678" # Replace with your Blue AMI ID
  instance_type = "t2.micro"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "green" {
  name_prefix   = "green-"
  image_id      = "ami-87654321" # Replace with your Green AMI ID
  instance_type = "t2.micro"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "blue" {
  name                      = "blue-group"
  max_size                  = 2
  min_size                  = 1
  desired_capacity          = 2
  vpc_zone_identifier       = ["subnet-12345"] # Replace with your subnet ID
  launch_configuration      = aws_launch_configuration.blue.id
  health_check_type         = "ELB"
  load_balancers            = [aws_elb.main.name]
  force_delete              = true
  wait_for_capacity_timeout = "0"
}

resource "aws_autoscaling_group" "green" {
  name                      = "green-group"
  max_size                  = 2
  min_size                  = 1
  desired_capacity          = 0 # Initially set to 0 to avoid receiving traffic
  vpc_zone_identifier       = ["subnet-54321"] # Replace with your subnet ID
  launch_configuration      = aws_launch_configuration.green.id
  health_check_type         = "ELB"
  load_balancers            = [aws_elb.main.name]
  force_delete              = true
  wait_for_capacity_timeout = "0"
}

# Output ELB DNS name so it can be accessed
output "elb_dns_name" {
  value = aws_elb.main.dns_name
}
