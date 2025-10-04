# API URL Configuration

## Overview

The VGL application uses dynamic API URL configuration that adapts between local development and AWS production deployment.

## Architecture

### Local Development
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8080
- **Direct container-to-container**: http://backend-prod:8080

### AWS Production
- **Frontend**: http://ALB_DNS_NAME
- **Backend API**: http://ALB_DNS_NAME/api
- **Health Check**: http://ALB_DNS_NAME/health

## Configuration Flow

### 1. Terraform Generates URLs
```hcl
# In terraform/outputs.tf
output "api_base_url" {
  description = "Base URL for API endpoints (for frontend configuration)"
  value       = "http://${aws_lb.main.dns_name}/api"
}

# In terraform/ecs.tf (Frontend Task Definition)
environment = [
  {
    name  = "NUXT_PUBLIC_API_BASE_URL_PROD"
    value = "http://${aws_lb.main.dns_name}/api"
  }
]
```

### 2. Load Balancer Routes Traffic
```hcl
# In terraform/load-balancer.tf
resource "aws_lb_listener_rule" "backend_api" {
  condition {
    path_pattern {
      values = ["/api/*", "/health"]
    }
  }
  # Routes /api/* requests to backend ECS service
}
```

### 3. Frontend Automatically Selects URL
```typescript
// In frontend/composables/useApi.ts
const config = useRuntimeConfig()
const environment = config.public.apiEnvironment

const baseURL = environment === 'prod' 
  ? config.public.apiBaseUrlProd    // From Terraform: http://ALB_DNS/api
  : config.public.apiBaseUrlDev     // Local dev: http://localhost:8080
```

## Environment Variable Strategy

### .env.development (Local)
```bash
NUXT_PUBLIC_API_BASE_URL_DEV=http://localhost:8080
```

### .env.production (Template)
```bash
# This gets overridden by ECS task definition from Terraform
NUXT_PUBLIC_API_BASE_URL_PROD=http://backend-prod:8080  # Docker compose fallback
```

### ECS Task Definition (Runtime)
```bash
# Injected by Terraform at deployment time
NUXT_PUBLIC_API_BASE_URL_PROD=http://vgl-challenge-prod-alb-123456789.us-east-1.elb.amazonaws.com/api
```

## Path Routing

The Application Load Balancer routes requests based on path:

| Path Pattern | Target Service | Example |
|--------------|----------------|---------|
| `/api/*` | Backend ECS | `/api/artists` → Backend |
| `/health` | Backend ECS | `/health` → Backend |
| `/*` | Frontend ECS | `/`, `/albums` → Frontend |

## Benefits

1. **Environment Agnostic**: Same frontend code works locally and in AWS
2. **Dynamic Configuration**: URLs generated at deployment time
3. **No Hardcoding**: Infrastructure determines the actual URLs
4. **Path-based Routing**: Single domain serves both frontend and API
5. **Health Checks**: Load balancer can check backend health

## Deployment Process

1. **Terraform Deploy**: Creates load balancer with dynamic DNS name
2. **ECS Task Update**: Frontend gets correct API URL via environment variable
3. **Frontend Runtime**: Nuxt automatically uses the correct base URL
4. **API Calls**: Frontend makes requests to `/api/*` which ALB routes to backend

## Getting the API URL

After Terraform deployment:

```bash
# Get the API base URL for frontend configuration
terraform output api_base_url

# Get the full application URL
terraform output application_url

# Example outputs:
# api_base_url = "http://vgl-challenge-prod-alb-123456789.us-east-1.elb.amazonaws.com/api"
# application_url = "http://vgl-challenge-prod-alb-123456789.us-east-1.elb.amazonaws.com"
```

This approach ensures that the frontend always knows how to reach the backend API, regardless of the deployment environment.
