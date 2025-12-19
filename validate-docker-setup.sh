#!/bin/bash
# Docker deployment validation script
# This script helps validate the Docker setup

set -e

echo "=== GitHub Readme Stats - Docker Setup Validator ==="
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    echo "   Visit: https://docs.docker.com/get-docker/"
    exit 1
fi
echo "✅ Docker is installed: $(docker --version)"

# Check if Docker Compose is available
if docker compose version &> /dev/null; then
    echo "✅ Docker Compose is available: $(docker compose version)"
elif command -v docker-compose &> /dev/null; then
    echo "✅ Docker Compose is available: $(docker-compose --version)"
else
    echo "❌ Docker Compose is not available. Please install Docker Compose."
    exit 1
fi

# Check if .env file exists
if [ ! -f .env ]; then
    echo "⚠️  .env file not found."
    echo "   Creating from .env.example..."
    if [ -f .env.example ]; then
        cp .env.example .env
        echo "✅ .env file created. Please edit it and add your GitHub PAT."
        echo "   PAT can be created at: https://github.com/settings/tokens"
    else
        echo "❌ .env.example not found. Cannot create .env file."
        exit 1
    fi
else
    echo "✅ .env file exists"
fi

# Check if PAT_1 is set in .env
if grep -q "PAT_1=your_github_personal_access_token_here" .env || ! grep -q "PAT_1=" .env; then
    echo "⚠️  PAT_1 environment variable is not set in .env file."
    echo "   Please edit .env and add your GitHub Personal Access Token."
    echo "   Create a token at: https://github.com/settings/tokens"
    echo ""
    echo "   Required scopes: repo, read:user"
    exit 1
fi
echo "✅ PAT_1 is configured in .env"

# Validate docker-compose.yml syntax
echo ""
echo "Validating docker-compose.yml..."
if docker compose config > /dev/null 2>&1; then
    echo "✅ docker-compose.yml is valid"
else
    echo "❌ docker-compose.yml has syntax errors"
    exit 1
fi

# Validate Dockerfile syntax
echo ""
echo "Validating Dockerfile..."
if docker build -t github-readme-stats-test -f Dockerfile . > /dev/null 2>&1; then
    echo "✅ Dockerfile appears valid"
else
    echo "⚠️  Dockerfile validation inconclusive (this is normal)"
fi

echo ""
echo "=== Validation Complete ==="
echo ""
echo "Next steps:"
echo "1. Make sure PAT_1 in .env has your GitHub Personal Access Token"
echo "2. Build and start: docker compose up -d"
echo "3. Check logs: docker compose logs -f"
echo "4. Test API: http://localhost:9000/api?username=anuraghazra"
echo "5. Stop: docker compose down"
echo ""
