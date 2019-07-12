#7/11/2019

terraform {
  required_version = ">= 0.12"
}


#Security Group to control access to the load balancer
resource "aws_security_group" "ALB-SG" {
  vpc_id = var.vpc_id

  #HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Outbound access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment_tag}-ALB-SG"
    Environment = var.environment_tag
  }
}


resource "aws_lb" "LoadBalancer" {
  name               = "${var.environment_tag}-ALB"
  internal           = false
  load_balancer_type = "application"

  #Subnet_ids is a data structure that contains multiple id's
  subnets         = flatten(var.subnet_ids)
  security_groups = [aws_security_group.ALB-SG.id]

  tags = {
    Name        = "${var.environment_tag}-ALB"
    Environment = var.environment_tag
  }
}

#Define a listener config for the ALB
resource "aws_lb_listener" "FE-Listener" {
  load_balancer_arn = aws_lb.LoadBalancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.FE-TargetGroup.arn
  }
}

#Create a Target Group to point the ALB to
resource "aws_lb_target_group" "FE-TargetGroup" {
  name     = "${var.environment_tag}-TargetGroup"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  tags = {
    Name        = "${var.environment_tag}-TargetGroup"
    Environment = var.environment_tag
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 10
    path                = "/index.html"
    port                = "80"
  }
}
