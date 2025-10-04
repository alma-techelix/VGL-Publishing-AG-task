# VGL DevOps Challenge - Implementation Plan

## Summary of Changes

I approached this challenge by breaking it down into practical phases that would make the applications both deployment-ready for AWS and easy to run locally.

### Containerization & Local Development

The first thing I tackled was getting both applications running in containers. The existing setup had some hardcoded values that would break in different environments, so I had to fix those.

**What I built:**
- Docker containers for both frontend and backend with multi-stage builds
- A docker-compose setup that lets developers run everything locally with one command  
- Environment configuration that works for both local dev and production
- Simple Makefile shortcuts so developers don't need to remember long docker commands

**Key fixes:**
- Removed hardcoded IP address (186.201.152.216) from the frontend code
- Set up proper environment variables so the frontend can find the backend
- Created separate database strategies: SQLite for local dev (zero setup) and MySQL for production
- Added health checks so services wait for dependencies to be ready
- Dynamic API URL configuration: frontend automatically uses correct backend URL (localhost for dev, load balancer DNS for production)

### AWS Infrastructure 

For AWS deployment, I built a complete Terraform infrastructure that follows best practices but stays cost-conscious.

**Infrastructure components:**
- VPC with public/private subnets across 2 availability zones
- ECS Fargate cluster to run the containers (no server management needed)
- Aurora MySQL database cluster for production data
- Application Load Balancer for traffic routing and SSL termination
- Auto-scaling policies to handle traffic spikes
- CloudWatch monitoring and alerting
- AWS Secrets Manager for secure database password storage

**Security improvements:**
- Database passwords stored in AWS Secrets Manager (never in plain text)
- ECS tasks automatically retrieve secrets at runtime
- IAM policies with least-privilege access to secrets

**Cost optimizations:**
- Made NAT Gateway optional (saves ~$45/month for dev environments)
- Configurable Multi-AZ deployment (high availability vs cost trade-off)
- Auto-scaling with sensible thresholds to avoid cost spikes
- Budget alerts at $100/month threshold

### CI/CD Pipeline

I set up GitHub Actions workflows that automatically test, build, and deploy the applications. Since this is for an interview and I don't have an AWS account, I made sure **80% of the CI/CD pipeline can be tested and demonstrated without any AWS setup**.

**Backend workflow:**
- Runs PHP tests (PHPUnit, PHPStan, PHPCS) with MySQL test database
- Builds Docker images for multiple architectures (AMD64/ARM64)
- Scans for security vulnerabilities with Trivy
- Integration tests with real API endpoint validation
- Publishes images to ECR on successful builds (AWS required)

**Frontend workflow:**
- Runs Node.js tests and linting (Vitest, ESLint, TypeScript)
- Builds production assets and validates Nuxt build
- Runs Lighthouse performance checks
- Builds and publishes Docker images (multi-arch)
- Integration tests with docker-compose stack

**What can be tested immediately:**
- Added manual workflow triggers so anyone can run the pipelines
- All testing, building, and security scanning works without AWS
- Created `test-cicd-demo.sh` script for easy demonstration
- Only the final deployment step requires AWS credentials (gracefully skipped)
- Results visible in GitHub Actions tab and Security tab

This means the interviewer can see the full CI/CD pipeline in action, including automated testing, Docker builds, security scans, and integration tests - all the valuable parts work perfectly without any cloud setup.

## Assumptions Made

1. **Database migration**: The existing SQLite data can be migrated to MySQL for production (schema looks compatible)
2. **Traffic patterns**: Assumed typical web application traffic that benefits from auto-scaling
3. **Security requirements**: Implemented standard practices but assumed no special compliance needs
4. **Budget constraints**: Designed for cost efficiency while maintaining production readiness
5. **Domain setup**: Infrastructure supports SSL certificates but assumes domain will be configured separately

## Architecture Decisions

**Why ECS Fargate over EKS?**
- Lower operational overhead (no cluster management)
- Better cost model for this workload size
- Faster deployment and scaling
- Built-in AWS service integrations

**Why Aurora MySQL over RDS MySQL?**
- Better performance for read-heavy workloads
- Automatic scaling storage
- Built-in high availability
- Better backup and recovery options

**Why multi-stage Docker builds?**
- Smaller production images (security and performance)
- Separate tooling for development vs production
- Better caching during builds

## Next Steps

If I had more time, here's what I'd tackle next:

### Long term :
1. **Multi-environment setup** - Separate dev/staging/prod environments
2. **Advanced monitoring** - APM integration (New Relic or DataDog)
3. **Disaster recovery** - Cross-region backup and failover procedures
4. **Security hardening** - WAF, advanced threat detection, compliance scanning
5. **CDN setup** - CloudFront distribution for static assets
6. **Monitoring dashboards** - Custom CloudWatch dashboards for application metrics
7. **SSL certificates** - Integrate with ACM for automatic certificate management

## Risks & Considerations

**Technical risks:**
- **Swoole compatibility**: Some PHP libraries might not work with the async Swoole server
- **Database migration**: Schema differences between SQLite and MySQL could require data transformation
- **Container resource limits**: May need tuning based on actual production workload

**Cost considerations:**
- **Auto-scaling thresholds**: Current settings are conservative but may need adjustment
- **Aurora costs**: Can be expensive for low-traffic applications (consider RDS MySQL alternative)
- **CloudWatch logs**: Verbose logging can add up, need log retention policies
- **Data transfer**: Consider VPC endpoints to reduce NAT Gateway costs

**Scaling considerations:**
- **Database connections**: Will need connection pooling for high-traffic scenarios
- **Session storage**: Current in-memory sessions won't work with multiple containers
- **Asset delivery**: Static assets should move to CloudFront for global performance

## What This Achieves

The solution provides:
- **One-command local development** that just works
- **Production-ready AWS infrastructure** with proper security and monitoring
- **Automated CI/CD pipeline** that catches issues before deployment
- **Cost-conscious design** with configurable high-availability features
- **Scalable architecture** that can grow with traffic demands
- **Interview-ready demonstration** - 80% of CI/CD works without AWS account

Both applications now run reliably in containers, can be deployed to AWS with Terraform, and have a solid foundation for future growth.

**For the interview:** The CI/CD pipeline can be fully demonstrated using the GitHub repository. Run `./test-cicd-demo.sh` to see automated testing, Docker builds, security scanning, and integration tests in action - no AWS setup required.
