#!/usr/bin/env bash
set -euo pipefail

# VGL DevOps Challenge - CI/CD Testing Script
# This script helps setup and test the GitHub Actions CI/CD pipeline

echo "🚀 VGL DevOps Challenge - CI/CD Testing Guide"
echo "=============================================="

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Not in a git repository. Initialize git first:"
    echo "   git init"
    echo "   git add ."
    echo "   git commit -m 'Initial commit'"
    echo "   git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git"
    echo "   git push -u origin main"
    exit 1
fi

echo ""
echo "📋 Prerequisites Checklist:"
echo "1. ✅ Git repository (detected)"
echo "2. ⚠️  GitHub repository created"
echo "3. ⚠️  AWS account with ECR access"
echo "4. ⚠️  GitHub repository secrets configured"

echo ""
echo "🔧 Required GitHub Repository Secrets:"
echo "======================================="
echo "Go to: https://github.com/YOUR_USERNAME/YOUR_REPO/settings/secrets/actions"
echo ""
echo "Required secrets:"
echo "• AWS_ROLE_TO_ASSUME       - ARN of IAM role for OIDC (arn:aws:iam::ACCOUNT:role/GitHubActionsRole)"
echo "• AWS_REGION              - AWS region (e.g., us-east-1)"
echo "• ECR_REPOSITORY          - ECR repository prefix (e.g., vgl-challenge)"
echo "• ECS_CLUSTER_NAME        - ECS cluster name (optional, for deployment)"
echo "• ECS_SERVICE_NAME        - ECS service prefix (optional, for deployment)"

echo ""
echo "🏗️  Step 1: Create ECR Repositories"
echo "===================================="
echo "Run these AWS CLI commands:"
echo ""
echo "# Create backend repository"
echo "aws ecr-public create-repository --repository-name vgl-challenge/vgl-backend --region us-east-1"
echo ""
echo "# Create frontend repository" 
echo "aws ecr-public create-repository --repository-name vgl-challenge/vgl-frontend --region us-east-1"

echo ""
echo "🔐 Step 2: Create IAM Role for GitHub OIDC"
echo "==========================================="
echo "Create IAM role with this trust policy:"
echo ""
cat << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::YOUR_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:YOUR_USERNAME/YOUR_REPO:*"
        }
      }
    }
  ]
}
EOF

echo ""
echo "Attach these managed policies to the role:"
echo "• AmazonEC2ContainerRegistryPowerUser"
echo "• AmazonECS_FullAccess (if using ECS deployment)"

echo ""
echo "🧪 Step 3: Test the CI/CD Pipeline"
echo "=================================="
echo "The workflows trigger on:"
echo "• Push to 'main' or 'develop' branches"
echo "• Changes in packages/backend/** or packages/frontend/**"
echo "• Changes to workflow files"

echo ""
echo "Test scenarios:"
echo ""

# Check current branch
current_branch=$(git rev-parse --abbrev-ref HEAD)
echo "Current branch: $current_branch"

if [[ "$current_branch" == "main" ]]; then
    echo "✅ On main branch - pushes will trigger full CI/CD including ECR publishing"
elif [[ "$current_branch" == "develop" ]]; then
    echo "✅ On develop branch - pushes will trigger CI/CD but no ECR publishing"
else
    echo "⚠️  Not on main/develop branch - limited CI/CD triggering"
fi

echo ""
echo "🔄 Quick Test Methods:"
echo "====================="
echo ""

echo "Method 1: Add a comment to trigger workflow"
echo "   # Add a comment to backend code"
echo "   echo '// CI/CD test' >> packages/backend/src/Router.php"
echo "   git add packages/backend/src/Router.php"
echo "   git commit -m 'test: trigger backend CI/CD'"
echo "   git push origin $current_branch"
echo ""

echo "Method 2: Update README to trigger workflow"
echo "   echo '' >> packages/frontend/README.md"
echo "   echo '<!-- CI/CD test -->' >> packages/frontend/README.md"
echo "   git add packages/frontend/README.md"
echo "   git commit -m 'test: trigger frontend CI/CD'"
echo "   git push origin $current_branch"
echo ""

echo "Method 3: Manually trigger workflow (if workflow_dispatch is enabled)"
echo "   Go to: https://github.com/YOUR_USERNAME/YOUR_REPO/actions"
echo "   Select workflow and click 'Run workflow'"

echo ""
echo "👀 Monitor Progress:"
echo "==================="
echo "1. GitHub Actions tab: https://github.com/YOUR_USERNAME/YOUR_REPO/actions"
echo "2. Watch for these jobs:"
echo "   • Backend: test → build → integration → deploy (main branch only)"
echo "   • Frontend: test → build → lighthouse → deploy (main branch only)"

echo ""
echo "✅ Verify Success:"
echo "=================="
echo "After successful pipeline run:"
echo ""
echo "1. Check ECR repositories for new images:"
echo "   aws ecr-public describe-images --repository-name vgl-challenge/vgl-backend --region us-east-1"
echo "   aws ecr-public describe-images --repository-name vgl-challenge/vgl-frontend --region us-east-1"
echo ""

echo "2. Pull and test images locally:"
echo "   docker pull public.ecr.aws/YOUR_ECR_PREFIX/vgl-challenge/vgl-backend:latest"
echo "   docker pull public.ecr.aws/YOUR_ECR_PREFIX/vgl-challenge/vgl-frontend:latest"
echo ""

echo "3. Test images work:"
echo "   docker run -p 8080:8080 public.ecr.aws/YOUR_ECR_PREFIX/vgl-challenge/vgl-backend:latest"
echo "   curl http://localhost:8080/health"

echo ""
echo "🚨 Troubleshooting:"
echo "==================="
echo "Common issues and solutions:"
echo ""
echo "• Authentication failed: Check AWS_ROLE_TO_ASSUME secret and IAM role trust policy"
echo "• ECR push failed: Verify ECR_REPOSITORY secret and repository exists"
echo "• Tests failing: Check local 'make smoke' works first"
echo "• Build failing: Verify Docker builds work locally"

echo ""
echo "📊 Expected Cost Impact:"
echo "========================"
echo "• GitHub Actions: Free for public repos, ~$0.008/minute for private"
echo "• ECR storage: ~$0.10/GB/month"
echo "• Data transfer: ~$0.09/GB"
echo "• Typical monthly cost: $1-5 for CI/CD"

echo ""
echo "🎯 Next Steps After Successful Test:"
echo "===================================="
echo "1. Use published images in Terraform:"
echo "   backend_image  = \"public.ecr.aws/YOUR_PREFIX/vgl-challenge/vgl-backend:latest\""
echo "   frontend_image = \"public.ecr.aws/YOUR_PREFIX/vgl-challenge/vgl-frontend:latest\""
echo ""
echo "2. Enable automatic ECS deployments (if using ECS)"
echo "3. Add branch protection rules requiring CI checks"
echo "4. Setup notification webhooks (Slack, email)"

echo ""
echo "🎉 Ready to test! Choose a method above and push your changes."
