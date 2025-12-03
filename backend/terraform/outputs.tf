output "instance_public_ip" {
  description = "ALB DNS name (use this instead of EC2 IP)"
  value       = aws_lb.app_alb.dns_name
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = aws_lb.app_alb.dns_name
}

output "alb_zone_id" {
  description = "ALB Zone ID (for Route53 alias records)"
  value       = aws_lb.app_alb.zone_id
}

output "asg_name" {
  description = "Auto-Scaling Group name"
  value       = aws_autoscaling_group.app_asg.name
}

# MongoDB Atlas Connection String
output "mongodb_connection_string" {
  description = "MongoDB Atlas connection string for the backend"
  value       = local.atlas_connection_string
  sensitive   = true
}

output "atlas_cluster_name" {
  description = "MongoDB Atlas cluster name"
  value       = mongodbatlas_cluster.tasktodo_cluster.name
}
