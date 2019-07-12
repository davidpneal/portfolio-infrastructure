#7/11/2019

variable "dns_domain" {
  description = "The apex domain to publish the site under, this resource should already exist in Route53"
  default     = ""
}

variable "dns_subdomain" {
  description = "The subdomain name for this site, will be appended to the apex domain specified below"
  default     = ""
}

variable "lb_dns_name" {
  description = "The DNS name for the load balancer, computed on resource creation"
}

variable "lb_zone_id" {
  description = "The hosted zone ID for the load balancer, computed on resource creation"
}

#Get the Route53 zone as this resource already exists in AWS
data "aws_route53_zone" "primary" {
  name = var.dns_domain
}
