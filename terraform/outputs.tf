# Infrastructure Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

# Load Balancer
output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the load balancer"
  value       = aws_lb.main.zone_id
}

output "application_url" {
  description = "URL to access the application"
  value       = "http://${aws_lb.main.dns_name}"
}

output "api_base_url" {
  description = "Base URL for API endpoints (for frontend configuration)"
  value       = "http://${aws_lb.main.dns_name}/api"
}

# ECS
output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "backend_service_name" {
  description = "Name of the backend ECS service"
  value       = aws_ecs_service.backend.name
}

output "frontend_service_name" {
  description = "Name of the frontend ECS service"
  value       = aws_ecs_service.frontend.name
}

# Database
output "rds_cluster_endpoint" {
  description = "RDS cluster endpoint"
  value       = aws_rds_cluster.main.endpoint
  sensitive   = true
}

output "rds_cluster_reader_endpoint" {
  description = "RDS cluster reader endpoint"
  value       = aws_rds_cluster.main.reader_endpoint
  sensitive   = true
}

output "database_secret_arn" {
  description = "ARN of the complete database connection secret"
  value       = aws_secretsmanager_secret.db_connection.arn
  sensitive   = true
}

# Monitoring
output "cloudwatch_dashboard_url" {
  description = "URL to CloudWatch dashboard"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}"
}

# Cost Information
output "estimated_monthly_cost" {
  description = "Estimated monthly cost breakdown"
  value = {
    fargate_tasks     = "$${var.desired_count * 2} * $30 (2 vCPU, 3GB RAM)"
    rds_aurora        = var.enable_multi_az ? "$120-200 (Multi-AZ)" : "$60-100 (Single AZ)"
    nat_gateway       = var.enable_nat_gateway ? "$45" : "$0"
    load_balancer     = "$20"
    cloudwatch_logs   = "$5-10"
    data_transfer     = "$10-50"
    total_estimated   = var.enable_multi_az ? "$200-315" : var.enable_nat_gateway ? "$140-225" : "$95-180"
  }
}
