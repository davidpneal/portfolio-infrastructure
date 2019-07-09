#7/9/2019
#A simple website running on a load balanced platform with autoscaling
#Requires the keypair and route53 domain to already exist in AWS

#Tested to work with Terraform .11.11 - version .12.2 does not work as written
terraform {
  required_version = "<= 0.12"
}

#Set provider
provider "aws" {
  region = "us-east-1"
}



#Variables defined in terraform.tfvars
variable "private_key_path" {
  description = "The path to the pem file which is assigned to the instances for SSH access"
}

variable "keypair_name" {
  description = "The name of the keypair in AWS used for SSH access"
}

variable "public_ip" {
  description = "A list of whitelisted addresses which are allowed SSH access to the instances"
}


variable "environment_tag" {
  description = "A descriptive tag which will be added to resources created by terraform"
  default = "portfolio-prod"
}


#VPC Configuration
variable "network_address_space" {
  description = "The VPC CIDR address"
  default = "10.1.0.0/16"
}

variable "subnet_count" {
  description = "The number of subnets - each subnet will be placed into a different AZ"
  default = 2 #Note that this value cannot be greater than the number of AZs in the Region
}


#AutoScaling Group Configuration
variable "min_instances" {
  description = "The minimum number of instances that the ASG will provision"
  default = 2
}

variable "max_instances" {
  description = "The maximum number of instances that the ASG will provision"
  default = 4
}

variable "image_id" {
  description = "The EC2 AMI to use in the launch configuration"
  default = "ami-035be7bafff33b6b6" #This AMI is ok for the US-E1 Region
}

variable "instance_type" {
  description = "The type of compute instance to use"
  default = "t2.micro"
}
 


#DNS Configuration
variable "dns_subdomain" {
  description = "The subdomain name for this site, will be appended to the apex domain"
  default = "demo"
}

variable "dns_domain" {
  description = "The apex domain to publish the site under, this resource should already exist in Route53"
  default = "davidpneal.com"
}



#Modules
module "networking" {
  source = "..\\..\\modules\\networking"

  environment_tag       = "${var.environment_tag}"
  network_address_space = "${var.network_address_space}"
  subnet_count          = "${var.subnet_count}"
}

module "alb" {
  source = "..\\..\\modules\\alb"

  environment_tag = "${var.environment_tag}"
  vpc_id          = "${module.networking.vpc_id}"
  subnet_ids      = ["${module.networking.subnet_ids}"]
}

module "autoscale" {
  source = "..\\..\\modules\\autoscale"

  environment_tag = "${var.environment_tag}"
  vpc_id          = "${module.networking.vpc_id}"
  subnet_ids      = ["${module.networking.subnet_ids}"]

  lb_target_group_arn = "${module.alb.arn}"
  min_instances       = "${var.min_instances}"
  max_instances       = "${var.max_instances}"
  image_id            = "${var.image_id}"
  instance_type       = "${var.instance_type}"

  keypair_name        = "${var.keypair_name}"
  public_ip           = "${var.public_ip}"
}

module "dns" {
  source = "..\\..\\modules\\dns"

  dns_domain    = "${var.dns_domain}"
  dns_subdomain = "${var.dns_subdomain}"
  lb_dns_name   = "${module.alb.dns_name}"
  lb_zone_id    = "${module.alb.zone_id}"
}

