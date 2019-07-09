#7/8/2019

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