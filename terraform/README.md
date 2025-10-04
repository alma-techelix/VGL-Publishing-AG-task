# VGL DevOps Challenge - Terraform Infrastructure

This directory contains Terraform configuration for deploying the VGL application to AWS.

## Architecture

The infrastructure includes:

- **VPC**: Custom VPC with public/private subnets across 2 AZs
- **ECS Fargate**: Containerized application deployment
- **Aurora MySQL**: Managed database cluster
- **Application Load Balancer**: Traffic distribution and SSL termination
- **CloudWatch**: Monitoring and logging
- **Auto Scaling**: Automatic scaling based on CPU utilization
- **Security**: Security groups, secrets management, encryption

## Quick Start

1. **Prerequisites**
   ```bash
   # Install Terraform >= 1.0
   # Configure AWS CLI with appropriate permissions
   aws configure
   ```

2. **Initialize Terraform**
   ```bash
   cd terraform
   terraform init
   ```

3. **Create terraform.tfvars**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

4. **Plan and Apply**
   ```bash
   terraform plan
   terraform apply
   ```

5. **Access Application**
   ```bash
   # Get the load balancer URL
   terraform output application_url
   ```

## Configuration

### Environment Variables

Copy and customize the example:
```bash
cp terraform.tfvars.example terraform.tfvars
```

Key variables to configure:
- `backend_image` / `frontend_image`: Your ECR image URIs
- `domain_name`: (Optional) Your domain for SSL certificate
- Cost optimization flags (see FinOps section)

### Container Images

Build and push your images to ECR:
```bash
# Backend
docker build -t vgl-backend packages/backend/
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com
docker tag vgl-backend:latest 123456789012.dkr.ecr.us-east-1.amazonaws.com/vgl-backend:latest
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/vgl-backend:latest

# Frontend
docker build -t vgl-frontend packages/frontend/
docker tag vgl-frontend:latest 123456789012.dkr.ecr.us-east-1.amazonaws.com/vgl-frontend:latest
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/vgl-frontend:latest
```

## FinOps Considerations

### Cost Optimization Options

| Feature | Monthly Cost | Description |
|---------|-------------|-------------|
| NAT Gateway | ~$45 | Internet access for private subnets |
| Multi-AZ RDS | ~$60 extra | High availability database |
| Fargate Tasks | ~$30/task | Based on CPU/memory allocation |

### Cost-Optimized Development
```hcl
enable_nat_gateway = false    # Use VPC endpoints instead
enable_multi_az   = false     # Single AZ for dev
desired_count     = 1         # Minimal task count
```

### Production Configuration
```hcl
enable_nat_gateway = true     # Internet access
enable_multi_az   = true      # High availability
desired_count     = 2         # Redundancy
```

### Monitoring Costs
- CloudWatch Dashboard: Included
- Budget Alerts: $100/month threshold
- Cost allocation tags: Automatic categorization

## Security

- **Encryption**: All data encrypted at rest and in transit
- **Secrets**: Database passwords stored in AWS Secrets Manager
- **Network**: Private subnets for application tier
- **IAM**: Least privilege access roles

## Monitoring

Access the CloudWatch dashboard:
```bash
terraform output cloudwatch_dashboard_url
```

Key metrics monitored:
- ECS CPU/Memory utilization
- Load balancer request metrics
- RDS performance metrics
- Auto scaling events

## Scaling

Auto scaling is configured for:
- **Target**: 70% CPU utilization
- **Min capacity**: 1 task
- **Max capacity**: 10 tasks

Adjust in `ecs-services.tf` if needed.

## Troubleshooting

### Common Issues

1. **Task won't start**
   ```bash
   aws ecs describe-services --cluster vgl-prod-cluster --services vgl-prod-backend
   aws logs get-log-events --log-group-name /ecs/vgl-prod-backend --log-stream-name ecs/backend/TASK_ID
   ```

2. **Health check failures**
   - Verify container port configuration
   - Check security group rules
   - Review application logs

3. **Database connection issues**
   - Verify RDS security group allows ECS access
   - Check database credentials in Secrets Manager
   - Validate VPC connectivity

### Useful Commands

```bash
# View infrastructure state
terraform show

# Update specific resources
terraform apply -target=aws_ecs_service.backend

# Clean up
terraform destroy
```

## Architecture Decisions

### ECS Fargate vs EC2
- **Chosen**: Fargate for serverless container management
- **Benefits**: No EC2 instance management, automatic scaling
- **Cost**: Higher per-task cost but lower operational overhead

### Aurora vs RDS MySQL
- **Chosen**: Aurora for better performance and scaling
- **Benefits**: Read replicas, backtrack, automatic failover
- **Cost**: ~20% premium over standard RDS

### Application Load Balancer
- **Features**: Path-based routing, health checks, SSL termination
- **Alternative**: Network Load Balancer for TCP traffic

## Next Steps

1. **DNS**: Configure Route 53 for custom domain
2. **CDN**: Add CloudFront for static asset delivery
3. **Backup**: Implement cross-region backup strategy
4. **Monitoring**: Add application-level monitoring (APM)
5. **CI/CD**: Integrate with existing GitHub Actions workflows
