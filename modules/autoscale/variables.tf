#7/9/2019

variable "environment_tag" {
  description = "A descriptive tag which will be added to resources created by terraform"
  default     = ""
}

variable "vpc_id" {
  description = "The VPC ID"
  default     = ""
}

variable "subnet_ids" {
  description = "A list of the subnets in the VPC"
  default     = [""]
}

variable "lb_target_group_arn" {
  description = "The load balancer target group where the ASG should create new instances"
  default     = ""
}


variable "min_instances" {
  description = "The minimum number of instances that the ASG will provision"
  default     = ""
}

variable "max_instances" {
  description = "The maximum number of instances that the ASG will provision"
  default     = ""
}

variable "image_id" {
  description = "The EC2 AMI to use in the launch configuration"
  default = ""
}

variable "instance_type" {
  description = "The type of compute instance to use"
  default = ""
}

variable "public_ip" {
  description = "A list of whitelisted addresses which are allowed SSH access to the instances"
  default = ""
}

variable "keypair_name" {
  description = "The name of the keypair in AWS used for SSH access"
  default = ""
}