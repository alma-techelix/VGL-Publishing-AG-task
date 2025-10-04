#==============================================================================
# VGL DEVOPS CHALLENGE - AWS INFRASTRUCTURE
#==============================================================================
# 
# This Terraform configuration deploys a production-ready infrastructure for
# the VGL challenge applications on AWS using modern best practices.
#
# Architecture:
# - VPC with public/private subnets across multiple AZs
# - ECS Fargate for containerized applications
# - Aurora MySQL for database
# - Application Load Balancer for traffic management
# - CloudWatch for monitoring and alerting
#
#==============================================================================

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
  
  # For production deployment, configure remote state backend:
  # backend "s3" {
  #   bucket         = "vgl-terraform-state-ACCOUNT-ID"
  #   key            = "infrastructure/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-lock"
  # }
}

#==============================================================================
# AWS PROVIDER CONFIGURATION
#==============================================================================

provider "aws" {
  region = var.aws_region
  
  # Apply consistent tags to all resources
  default_tags {
    tags = {
      Project     = "vgl-devops-challenge"
      Environment = var.environment
      ManagedBy   = "terraform"
      Owner       = "devops-team"
      CostCenter  = "engineering"
    }
  }
}

#==============================================================================
# LOCAL VALUES AND NAMING CONVENTIONS
#==============================================================================

locals {
  # Consistent naming prefix for all resources
  name_prefix = "${var.project_name}-${var.environment}"
  
  # Common tags applied to all resources
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Repository  = "vgl-devops-challenge"
  }
}

#==============================================================================
# DATA SOURCES
#==============================================================================

# Get available AZs in the selected region
data "aws_availability_zones" "available" {
  state = "available"
}

# Get current AWS account information
data "aws_caller_identity" "current" {}

# Get current region information
data "aws_region" "current" {}
