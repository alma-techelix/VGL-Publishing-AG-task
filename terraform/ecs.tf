#==============================================================================
# ELASTIC CONTAINER SERVICE (ECS) CONFIGURATION
#==============================================================================
#
# This file configures the container orchestration layer:
# - ECS Fargate cluster for serverless containers
# - IAM roles for task execution and application permissions
# - Task definitions for backend and frontend applications
# - Secrets Manager integration for secure database access
#
#==============================================================================

#------------------------------------------------------------------------------
# ECS Cluster - Container Orchestration Platform
#------------------------------------------------------------------------------

resource "aws_ecs_cluster" "main" {
  name = "${local.name_prefix}-cluster"
  
  # Enable CloudWatch Container Insights for monitoring
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  
  tags = merge(local.common_tags, {
    Name        = "${local.name_prefix}-ecs-cluster"
    Description = "ECS Fargate cluster for VGL applications"
  })
}

#------------------------------------------------------------------------------
# Capacity Providers - Serverless Container Execution
#------------------------------------------------------------------------------

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name
  
  # Use Fargate for reliable, consistent performance
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  
  default_capacity_provider_strategy {
    base              = 1      # Minimum tasks on regular Fargate
    weight            = 100    # Prefer regular Fargate over Spot
    capacity_provider = "FARGATE"
  }
}

#------------------------------------------------------------------------------
# IAM Role - ECS Task Execution (Infrastructure Permissions)
#------------------------------------------------------------------------------

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${local.name_prefix}-ecs-task-execution-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
  
  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Custom policy for Secrets Manager access
resource "aws_iam_role_policy" "ecs_secrets_policy" {
  name = "${local.name_prefix}-ecs-secrets-policy"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          aws_secretsmanager_secret.db_connection.arn
        ]
      }
    ]
  })
}

# IAM Role for ECS Tasks (application permissions)
resource "aws_iam_role" "ecs_task_role" {
  name = "${local.name_prefix}-ecs-task-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
  
  tags = local.common_tags
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "backend" {
  name              = "/ecs/${local.name_prefix}-backend"
  retention_in_days = 7
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-backend-logs"
  })
}

resource "aws_cloudwatch_log_group" "frontend" {
  name              = "/ecs/${local.name_prefix}-frontend"
  retention_in_days = 7
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-frontend-logs"
  })
}

# Generate DB password
resource "random_password" "db_password" {
  length  = 16
  special = true
}

# Store complete DB connection details in Secrets Manager
resource "aws_secretsmanager_secret" "db_connection" {
  name        = "${local.name_prefix}-db-connection"
  description = "Complete database connection configuration for VGL application"
  
  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "db_connection" {
  secret_id = aws_secretsmanager_secret.db_connection.id
  secret_string = jsonencode({
    DB_DRIVER = "mysql"
    DB_HOST   = aws_rds_cluster.main.endpoint
    DB_PORT   = "3306"
    DB_NAME   = var.db_name
    DB_USER   = var.db_username
    DB_PASS   = random_password.db_password.result
  })
  
  # Ensure RDS cluster is created before storing connection details
  depends_on = [aws_rds_cluster.main]
}

# Backend Task Definition
resource "aws_ecs_task_definition" "backend" {
  family                   = "${local.name_prefix}-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.backend_cpu
  memory                   = var.backend_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn           = aws_iam_role.ecs_task_role.arn
  
  container_definitions = jsonencode([
    {
      name         = "backend"
      image        = var.backend_image != "" ? var.backend_image : "public.ecr.aws/docker/library/php:8.3-cli-alpine"
      essential    = true
      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "HTTP_HOST"
          value = "0.0.0.0"
        },
        {
          name  = "HTTP_PORT"
          value = "8080"
        }
      ]
      secrets = [
        {
          name      = "DB_DRIVER"
          valueFrom = "${aws_secretsmanager_secret.db_connection.arn}:DB_DRIVER::"
        },
        {
          name      = "DB_HOST"
          valueFrom = "${aws_secretsmanager_secret.db_connection.arn}:DB_HOST::"
        },
        {
          name      = "DB_PORT"
          valueFrom = "${aws_secretsmanager_secret.db_connection.arn}:DB_PORT::"
        },
        {
          name      = "DB_NAME"
          valueFrom = "${aws_secretsmanager_secret.db_connection.arn}:DB_NAME::"
        },
        {
          name      = "DB_USER"
          valueFrom = "${aws_secretsmanager_secret.db_connection.arn}:DB_USER::"
        },
        {
          name      = "DB_PASS"
          valueFrom = "${aws_secretsmanager_secret.db_connection.arn}:DB_PASS::"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.backend.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:8080/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-backend-task"
  })
}

# Frontend Task Definition
resource "aws_ecs_task_definition" "frontend" {
  family                   = "${local.name_prefix}-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.frontend_cpu
  memory                   = var.frontend_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn           = aws_iam_role.ecs_task_role.arn
  
  container_definitions = jsonencode([
    {
      name         = "frontend"
      image        = var.frontend_image != "" ? var.frontend_image : "public.ecr.aws/docker/library/node:20-alpine"
      essential    = true
      portMappings = [
        {
          containerPort = 3000
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "NUXT_PUBLIC_API_ENVIRONMENT"
          value = "prod"
        },
        {
          name  = "NUXT_PUBLIC_API_BASE_URL_PROD"
          value = "http://${aws_lb.main.dns_name}/api"
        },
        {
          name  = "PORT"
          value = "3000"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.frontend.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:3000 || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-frontend-task"
  })
}
