# GitHub Repository Configuration for VGL DevOps Challenge

## Required Repository Secrets

The following secrets must be configured in the GitHub repository settings:

### AWS Configuration
- `AWS_ROLE_TO_ASSUME`: IAM role ARN for GitHub Actions OIDC
- `AWS_REGION`: AWS region (e.g., us-east-1)
- `ECR_REPOSITORY`: ECR repository alias/name
- `ECS_CLUSTER_NAME`: ECS cluster name
- `ECS_SERVICE_NAME`: Base name for ECS services (will append -backend, -frontend)

### Application URLs (for health checks)
- `BACKEND_URL`: Production backend URL
- `FRONTEND_URL`: Production frontend URL

### Notifications (optional)
- `SLACK_WEBHOOK_URL`: Slack webhook for deployment notifications

## Required Repository Settings

### Branch Protection Rules
Enable the following for the `main` branch:
- Require pull request reviews before merging
- Require status checks to pass before merging
  - Backend CI/CD
  - Frontend CI/CD
  - Security Scan
- Require branches to be up to date before merging
- Restrict pushes to matching branches

### Security Settings
- Enable Dependabot alerts
- Enable Dependabot security updates
- Enable Dependabot version updates
- Enable secret scanning
- Enable push protection for secret scanning

### Actions Settings
- Allow GitHub Actions
- Allow actions and reusable workflows created by GitHub
- Allow actions by Marketplace verified creators
- Allow specified actions (add any custom actions if needed)

## AWS IAM Role Setup

Create an IAM role with the following trust policy for GitHub Actions OIDC:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::ACCOUNT-ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
          "token.actions.githubusercontent.com:sub": "repo:YOUR-ORG/YOUR-REPO:ref:refs/heads/main"
        }
      }
    }
  ]
}
```

Attach the following managed policies:
- `AmazonECS_FullAccess` (or custom policy with minimal required permissions)
- `AmazonEC2ContainerRegistryPowerUser`

## Environment-Specific Configuration

### Development Environment
- Branch: `develop`
- Cluster: `vgl-development`
- Database: Development RDS instance or Aurora Serverless

### Staging Environment
- Branch: `staging`
- Cluster: `vgl-staging`
- Database: Staging RDS instance

### Production Environment
- Branch: `main`
- Cluster: `vgl-production`
- Database: Production RDS with Multi-AZ

## Monitoring and Alerting

Consider setting up:
- CloudWatch dashboards for application metrics
- CloudWatch alarms for critical metrics
- AWS SNS topics for alert notifications
- Integration with PagerDuty or similar for incident management

## Cost Optimization

- Use Spot instances for development/staging ECS tasks
- Configure auto-scaling policies based on CPU/memory utilization
- Set up AWS Budgets to monitor spending
- Use Reserved Instances for predictable production workloads
- Implement lifecycle policies for ECR repositories to clean up old images
