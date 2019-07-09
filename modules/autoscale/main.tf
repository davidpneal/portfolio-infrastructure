#7/9/2019

#Security Group to control access to the web server
resource "aws_security_group" "WebServer-SG" {
  vpc_id = "${var.vpc_id}"

  #SSH access from a whitelisted address
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.public_ip}"]
  }

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

  tags {
    Name        = "${var.environment_tag}-WebServer-SG"
    Environment = "${var.environment_tag}"
  }
}

#Define the Launch Configuration
resource "aws_launch_configuration" "Launch-Config" {
  name_prefix            = "${var.environment_tag}-LC-" #TF documentation recc not using a name since the LC is recreated if changed
  image_id               = "${var.image_id}"
  instance_type          = "${var.instance_type}"
  security_groups        = ["${aws_security_group.WebServer-SG.id}"]
  key_name               = "${var.keypair_name}"

  #User data takes the bootstrap script - documentation indicates this can be a cloud-init script or a standard shell script
  #This relative path is evaluated as if it were run from the root module folder
  user_data = "${file("..\\webserver-init.sh")}"

  lifecycle {
    create_before_destroy = true #If changed, create the new LC before destroying the old one
  }
}

#Create the AutoScaling Group
resource "aws_autoscaling_group" "ASG" {
  name                  = "${var.environment_tag}-ASG"
  launch_configuration  = "${aws_launch_configuration.Launch-Config.id}"
  vpc_zone_identifier   = ["${var.subnet_ids}"] #list of subnet IDs to launch resources into
  min_size              = "${var.min_instances}"
  max_size              = "${var.max_instances}"
  health_check_type     = "ELB"
  enabled_metrics       = [""] #Enables Group Metrics Collection for all metrics
  
  tag {
    key   = "Name"
    value = "${var.environment_tag}-ASG-Instance"
    propagate_at_launch = true #Required so the ASG can propagate the tag to the EC2 instances it creates
  }
}

#Scale Up Policy and Alarm
resource "aws_autoscaling_policy" "Scale-Up" {
  name                   = "Scale-Up-Policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.ASG.name}"
}

resource "aws_cloudwatch_metric_alarm" "Scale-Up-Alarm" {
  alarm_name                = "Scale-Up-Alarm"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "80"
  insufficient_data_actions = []

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.ASG.name}"
  }

  alarm_description = "EC2 High CPU Utilization"
  alarm_actions     = ["${aws_autoscaling_policy.Scale-Up.arn}"]
}

#Scale Down Policy and Alarm
resource "aws_autoscaling_policy" "Scale-Down" {
  name                   = "Scale-Down-Policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 600
  autoscaling_group_name = "${aws_autoscaling_group.ASG.name}"
}

resource "aws_cloudwatch_metric_alarm" "Scale-Down-Alarm" {
  alarm_name                = "Scale-Down-Alarm"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = "5"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "30"
  insufficient_data_actions = []

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.ASG.name}"
  }

  alarm_description = "EC2 Low CPU Utilization"
  alarm_actions     = ["${aws_autoscaling_policy.Scale-Down.arn}"]
}

#Attach the Target Group to the Autoscaling Group
resource "aws_autoscaling_attachment" "TG-ASG-Attach" {
  alb_target_group_arn   = "${var.lb_target_group_arn}"
  autoscaling_group_name = "${aws_autoscaling_group.ASG.id}"
}