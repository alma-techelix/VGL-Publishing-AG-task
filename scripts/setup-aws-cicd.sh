#!/usr/bin/env bash
set -euo pipefail

# VGL DevOps Challenge - AWS Setup for CI/CD
# This script creates the required AWS resources for GitHub Actions

echo "🏗️  VGL DevOps Challenge - AWS CI/CD Setup"
echo "=========================================="

# Check AWS CLI is installed and configured
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI not found. Please install and configure it first:"
    echo "   https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    exit 1
fi

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS credentials not configured. Run 'aws configure' first."
    exit 1
fi

# Get AWS account ID and current region
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=$(aws configure get region || echo "us-east-1")

echo "✅ AWS Account ID: $AWS_ACCOUNT_ID"
echo "✅ AWS Region: $AWS_REGION"

# Prompt for GitHub repository details
read -p "Enter your GitHub username: " GITHUB_USERNAME
read -p "Enter your GitHub repository name: " GITHUB_REPO
read -p "Enter ECR repository prefix (default: vgl-challenge): " ECR_PREFIX
ECR_PREFIX=${ECR_PREFIX:-vgl-challenge}

echo ""
echo "📋 Configuration Summary:"
echo "========================"
echo "GitHub Repository: $GITHUB_USERNAME/$GITHUB_REPO"
echo "ECR Prefix: $ECR_PREFIX"
echo "AWS Account: $AWS_ACCOUNT_ID"
echo "AWS Region: $AWS_REGION"
echo ""

read -p "Continue with setup? (y/N): " -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Setup cancelled."
    exit 1
fi

echo ""
echo "🔗 Step 1: Create GitHub OIDC Provider (if not exists)"
echo "======================================================"

# Check if OIDC provider exists
if aws iam get-open-id-connect-provider --open-id-connect-provider-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com" &> /dev/null; then
    echo "✅ GitHub OIDC provider already exists"
else
    echo "Creating GitHub OIDC provider..."
    aws iam create-open-id-connect-provider \
        --url https://token.actions.githubusercontent.com \
        --client-id-list sts.amazonaws.com \
        --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1 \
        --tags Key=Project,Value=vgl-challenge Key=Purpose,Value=github-actions
    echo "✅ GitHub OIDC provider created"
fi

echo ""
echo "🔐 Step 2: Create IAM Role for GitHub Actions"
echo "============================================="

ROLE_NAME="GitHubActions-${ECR_PREFIX}-Role"

# Create trust policy
cat > /tmp/github-trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:${GITHUB_USERNAME}/${GITHUB_REPO}:*"
        }
      }
    }
  ]
}
EOF

# Check if role exists
if aws iam get-role --role-name "$ROLE_NAME" &> /dev/null; then
    echo "⚠️  Role $ROLE_NAME already exists. Updating trust policy..."
    aws iam update-assume-role-policy --role-name "$ROLE_NAME" --policy-document file:///tmp/github-trust-policy.json
else
    echo "Creating IAM role: $ROLE_NAME"
    aws iam create-role \
        --role-name "$ROLE_NAME" \
        --assume-role-policy-document file:///tmp/github-trust-policy.json \
        --tags Key=Project,Value=vgl-challenge Key=Purpose,Value=github-actions
fi

# Attach required policies
echo "Attaching ECR permissions..."
aws iam attach-role-policy \
    --role-name "$ROLE_NAME" \
    --policy-arn arn:aws:iam::aws:policy/AmazonElasticContainerRegistryPublicPowerUser

echo "Attaching ECS permissions (for deployment)..."
aws iam attach-role-policy \
    --role-name "$ROLE_NAME" \
    --policy-arn arn:aws:iam::aws:policy/AmazonECS_FullAccess

ROLE_ARN="arn:aws:iam::${AWS_ACCOUNT_ID}:role/${ROLE_NAME}"
echo "✅ IAM Role created: $ROLE_ARN"

echo ""
echo "📦 Step 3: Create ECR Repositories"
echo "=================================="

# Backend repository
BACKEND_REPO="${ECR_PREFIX}/vgl-backend"
echo "Creating backend repository: $BACKEND_REPO"
if aws ecr-public describe-repositories --repository-names "$BACKEND_REPO" --region us-east-1 &> /dev/null; then
    echo "⚠️  Backend repository already exists"
else
    aws ecr-public create-repository \
        --repository-name "$BACKEND_REPO" \
        --region us-east-1 \
        --tags Key=Project,Value=vgl-challenge Key=Application,Value=backend
    echo "✅ Backend repository created"
fi

# Frontend repository
FRONTEND_REPO="${ECR_PREFIX}/vgl-frontend"
echo "Creating frontend repository: $FRONTEND_REPO"
if aws ecr-public describe-repositories --repository-names "$FRONTEND_REPO" --region us-east-1 &> /dev/null; then
    echo "⚠️  Frontend repository already exists"
else
    aws ecr-public create-repository \
        --repository-name "$FRONTEND_REPO" \
        --region us-east-1 \
        --tags Key=Project,Value=vgl-challenge Key=Application,Value=frontend
    echo "✅ Frontend repository created"
fi

echo ""
echo "🎯 Step 4: GitHub Repository Secrets"
echo "===================================="
echo "Add these secrets to your GitHub repository:"
echo "Go to: https://github.com/$GITHUB_USERNAME/$GITHUB_REPO/settings/secrets/actions"
echo ""
echo "Required secrets:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Name: AWS_ROLE_TO_ASSUME"
echo "Value: $ROLE_ARN"
echo ""
echo "Name: AWS_REGION"
echo "Value: $AWS_REGION"
echo ""
echo "Name: ECR_REPOSITORY"
echo "Value: $ECR_PREFIX"
echo ""
echo "Name: ECS_CLUSTER_NAME (optional - for ECS deployment)"
echo "Value: vgl-prod-cluster"
echo ""
echo "Name: ECS_SERVICE_NAME (optional - for ECS deployment)"  
echo "Value: vgl-prod"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "🧪 Step 5: Test the Setup"
echo "========================="
echo "Run the CI/CD test script:"
echo "   chmod +x scripts/test-cicd.sh"
echo "   ./scripts/test-cicd.sh"

echo ""
echo "📊 Resources Created Summary:"
echo "============================"
echo "• OIDC Provider: token.actions.githubusercontent.com"
echo "• IAM Role: $ROLE_ARN"  
echo "• ECR Backend: public.ecr.aws/$BACKEND_REPO"
echo "• ECR Frontend: public.ecr.aws/$FRONTEND_REPO"

echo ""
echo "💰 Estimated Monthly Costs:"
echo "==========================="
echo "• GitHub Actions: Free (public repo) or ~$0.008/minute (private)"
echo "• ECR Public: Free for first 50GB/month"
echo "• IAM/OIDC: Free"
echo "• Total: $0-5/month depending on usage"

echo ""
echo "🎉 AWS setup complete! Configure GitHub secrets and test the pipeline."

# Cleanup temp files
rm -f /tmp/github-trust-policy.json
