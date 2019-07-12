#7/11/2019

output "arn" {
  value = aws_lb_target_group.FE-TargetGroup.arn
}

output "dns_name" {
  value = aws_lb.LoadBalancer.dns_name
}

output "zone_id" {
  value = aws_lb.LoadBalancer.zone_id
}
