#!/bin/bash

# CI/CD Testing Demo Script
# This script demonstrates what can be tested without AWS

echo "🚀 VGL DevOps Challenge - CI/CD Testing Demo"
echo "============================================="
echo ""

# Check if we're in a git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "❌ Error: Not in a git repository"
    echo "Please run this script from the project root directory"
    exit 1
fi

echo "✅ Git repository detected"

# Check if GitHub remote exists
if git remote get-url origin > /dev/null 2>&1; then
    REPO_URL=$(git remote get-url origin)
    echo "✅ GitHub remote found: $REPO_URL"
else
    echo "❌ No GitHub remote found. Please push to GitHub first."
    exit 1
fi

echo ""
echo "🔍 Available CI/CD Tests (No AWS Required)"
echo "=========================================="
echo ""
echo "1. 🧪 Automated Testing Pipeline"
echo "   - PHP 8.3 with PHPUnit, PHPStan, PHPCS"
echo "   - Node.js 20 with Vitest, ESLint, TypeScript"
echo "   - MySQL integration testing"
echo ""
echo "2. 🐳 Docker Multi-Arch Builds"
echo "   - AMD64 and ARM64 architectures"
echo "   - Multi-stage builds (dev/prod)"
echo "   - Layer caching optimization"
echo ""
echo "3. 🔒 Security Scanning"
echo "   - Trivy vulnerability scanner"
echo "   - SARIF reports in GitHub Security tab"
echo "   - Dependency vulnerability checks"
echo ""
echo "4. 🔗 Integration Testing"
echo "   - Full docker-compose stack testing"
echo "   - API endpoint validation"
echo "   - Health check verification"
echo ""

echo "💡 How to Test:"
echo "==============="
echo ""
echo "Option 1: Manual Workflow Trigger (Recommended)"
echo "  1. Go to: ${REPO_URL/git@github.com:/https://github.com/}/actions"
echo "  2. Click 'Backend CI/CD' or 'Frontend CI/CD'"
echo "  3. Click 'Run workflow' button"
echo "  4. Leave 'Skip deployment step' checked (since no AWS)"
echo "  5. Click 'Run workflow'"
echo ""

echo "Option 2: Trigger with Code Change"
echo "  # Make a small change to trigger workflows"
echo "  echo '// Test CI/CD' >> packages/backend/src/Router.php"
echo "  git add ."
echo "  git commit -m 'test: trigger CI/CD pipeline'"
echo "  git push origin main"
echo ""

echo "Option 3: Local Testing with Act"
echo "  # Install act: brew install act"
echo "  # Run backend tests locally:"
echo "  act -W .github/workflows/backend.yml -j test"
echo ""

echo "🎯 What You'll See Working:"
echo "=========================="
echo "✅ PHP and Node.js testing suites"
echo "✅ Code quality checks (linting, static analysis)"
echo "✅ Docker image builds (without publishing)"
echo "✅ Security vulnerability scanning"
echo "✅ Integration tests with real database"
echo "✅ Multi-architecture builds"
echo ""

echo "❌ What Won't Work (AWS Required):"
echo "================================="
echo "❌ ECR image publishing (needs AWS credentials)"
echo "❌ ECS deployment (needs AWS infrastructure)"
echo "❌ 'deploy' job will be skipped"
echo ""

echo "📊 Expected Results:"
echo "==================="
echo "• Testing jobs: ✅ PASS"
echo "• Building jobs: ✅ PASS" 
echo "• Security jobs: ✅ PASS"
echo "• Integration jobs: ✅ PASS"
echo "• Deploy jobs: ⏭️ SKIPPED (no AWS)"
echo ""

echo "🔗 Monitor Results At:"
echo "====================="
echo "${REPO_URL/git@github.com:/https://github.com/}/actions"
echo ""

read -p "🚀 Ready to trigger a test workflow? (y/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "🎯 Triggering backend workflow test..."
    echo ""
    
    # Create a harmless change to trigger the workflow
    echo "// CI/CD test triggered at $(date)" >> packages/backend/src/Router.php
    
    git add packages/backend/src/Router.php
    git commit -m "test: trigger CI/CD pipeline demonstration"
    
    echo "📤 Pushing to GitHub..."
    git push origin $(git branch --show-current)
    
    echo ""
    echo "✅ Workflow triggered!"
    echo "🔗 Watch the results at: ${REPO_URL/git@github.com:/https://github.com/}/actions"
    echo ""
    echo "Expected timeline:"
    echo "• Testing: ~2-3 minutes"
    echo "• Building: ~3-4 minutes" 
    echo "• Security scanning: ~1-2 minutes"
    echo "• Integration tests: ~2-3 minutes"
    echo "• Total: ~8-12 minutes"
    echo ""
else
    echo ""
    echo "👍 No problem! You can trigger tests manually later:"
    echo "   1. Visit: ${REPO_URL/git@github.com:/https://github.com/}/actions"
    echo "   2. Click 'Backend CI/CD' → 'Run workflow'"
    echo "   3. Ensure 'Skip deployment step' is checked"
    echo "   4. Click 'Run workflow'"
    echo ""
fi

echo "📚 For more details, see: CI_CD_TESTING.md"
echo ""
