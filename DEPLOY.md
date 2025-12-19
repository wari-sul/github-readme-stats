# Docker Deployment Guide

This guide explains how to deploy GitHub Readme Stats using Docker and Docker Compose, including deployment on Coolify and other Docker-based platforms.

> **🚀 Quick Start for Coolify Users:**  
> Jump directly to the [Deploy on Coolify](#deploy-on-coolify) section for step-by-step Coolify deployment instructions.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start with Docker Compose](#quick-start-with-docker-compose)
- [Deploy on Coolify](#deploy-on-coolify)
- [Deploy with Docker CLI](#deploy-with-docker-cli)
- [Environment Variables](#environment-variables)
- [Health Checks](#health-checks)
- [Troubleshooting](#troubleshooting)

## Prerequisites

1. **Docker** and **Docker Compose** installed on your system
2. **GitHub Personal Access Token (PAT)** - Required for accessing GitHub API

### Creating a GitHub Personal Access Token

#### Classic Token (Recommended)

1. Go to [GitHub Settings → Developer Settings → Personal Access Tokens → Tokens (classic)](https://github.com/settings/tokens)
2. Click "Generate new token" → "Generate new token (classic)"
3. Select the following scopes:
   - `repo` - Full control of private repositories
   - `read:user` - Read user profile data
4. Click "Generate token" and copy it immediately (you won't see it again!)

#### Fine-grained Token

1. Go to [GitHub Settings → Developer Settings → Personal Access Tokens → Fine-grained tokens](https://github.com/settings/tokens?type=beta)
2. Click "Generate new token"
3. Set an expiration date and select "All repositories"
4. Under "Repository permissions", select:
   - Commit statuses: Read-only
   - Contents: Read-only
   - Issues: Read-only
   - Metadata: Read-only
   - Pull requests: Read-only
5. Click "Generate token" and copy it

## Quick Start with Docker Compose

1. **Clone the repository:**

   ```bash
   git clone https://github.com/anuraghazra/github-readme-stats.git
   cd github-readme-stats
   ```

2. **Create environment file:**

   ```bash
   cp .env.example .env
   ```

3. **Edit `.env` and add your GitHub PAT:**

   ```env
   PAT_1=ghp_your_personal_access_token_here
   PORT=9000
   ```

4. **Start the service:**

   ```bash
   docker-compose up -d
   ```

5. **Verify it's running:**

   ```bash
   docker-compose ps
   docker-compose logs -f
   ```

6. **Test the API:**

   Open your browser and visit:
   ```
   http://localhost:9000/api?username=anuraghazra
   ```

7. **Stop the service:**

   ```bash
   docker-compose down
   ```

## Deploy on Coolify

[Coolify](https://coolify.io/) is a self-hosted Heroku/Netlify/Vercel alternative that makes deploying applications easy.

### Method 1: Using Git Repository (Recommended)

1. **Fork this repository** to your GitHub account

2. **In Coolify Dashboard:**
   - Click "New Resource"
   - Select "Docker Compose"
   - Choose "Public Repository" or connect your GitHub account
   - Enter your repository URL: `https://github.com/yourusername/github-readme-stats`
   - Set the branch (e.g., `master`)

3. **Configure Environment Variables:**
   
   In Coolify's environment variables section, add:
   ```
   PAT_1=ghp_your_personal_access_token_here
   PORT=9000
   CACHE_SECONDS=86400
   ```

4. **Configure Port Mapping:**
   - Coolify will automatically detect the exposed port (9000)
   - Set up a domain or use the provided Coolify URL

5. **Deploy:**
   - Click "Deploy"
   - Coolify will build and deploy your application

### Method 2: Using Docker Image

1. **In Coolify Dashboard:**
   - Click "New Resource"
   - Select "Docker Image"
   - Use build context from Git repository

2. **Configure:**
   - Repository: Your forked repository URL
   - Dockerfile Path: `./Dockerfile`
   - Build Arguments: (none needed)

3. **Environment Variables:**
   
   Add the same environment variables as Method 1

4. **Deploy**

### Accessing Your Deployment

Once deployed, Coolify will provide you with a URL. You can access your instance at:

```
https://your-app.coolify.example.com/api?username=yourusername
```

### Custom Domain

In Coolify, you can add a custom domain:
1. Go to your application settings
2. Add your domain in the "Domains" section
3. Update your DNS records as instructed
4. Coolify will automatically provision SSL certificates via Let's Encrypt

## Deploy with Docker CLI

### Build the Image

```bash
docker build -t github-readme-stats .
```

### Run the Container

```bash
docker run -d \
  --name github-readme-stats \
  -p 9000:9000 \
  -e PAT_1=ghp_your_personal_access_token_here \
  -e PORT=9000 \
  -e CACHE_SECONDS=86400 \
  --restart unless-stopped \
  github-readme-stats
```

### Using Environment File

```bash
docker run -d \
  --name github-readme-stats \
  -p 9000:9000 \
  --env-file .env \
  --restart unless-stopped \
  github-readme-stats
```

### Check Logs

```bash
docker logs -f github-readme-stats
```

### Stop and Remove

```bash
docker stop github-readme-stats
docker rm github-readme-stats
```

## Environment Variables

All environment variables are optional except `PAT_1`.

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `PAT_1` | GitHub Personal Access Token | - | ✅ Yes |
| `PORT` | Port for the server | `9000` | No |
| `CACHE_SECONDS` | Cache duration in seconds (0 to disable) | `86400` (24h) | No |
| `WHITELIST` | Comma-separated list of allowed GitHub usernames | - | No |
| `GIST_WHITELIST` | Comma-separated list of allowed Gist IDs | - | No |
| `EXCLUDE_REPO` | Comma-separated list of repositories to exclude from stats | - | No |
| `FETCH_MULTI_PAGE_STARS` | Enable fetching all starred repos (`true`/`false`) | `false` | No |

### Example with All Variables

```env
PAT_1=ghp_your_token_here
PORT=3000
CACHE_SECONDS=43200
WHITELIST=user1,user2,user3
GIST_WHITELIST=abc123,def456
EXCLUDE_REPO=repo1,repo2
FETCH_MULTI_PAGE_STARS=true
```

## Health Checks

The Docker Compose configuration includes automatic health checks. The container will be marked as healthy when the API responds correctly.

Check health status:

```bash
docker-compose ps
```

Or with Docker CLI:

```bash
docker inspect --format='{{json .State.Health}}' github-readme-stats
```

## Troubleshooting

### Container Won't Start

1. **Check logs:**
   ```bash
   docker-compose logs -f
   ```

2. **Verify environment variables:**
   ```bash
   docker-compose config
   ```

3. **Check if PAT_1 is set:**
   ```bash
   docker exec github-readme-stats env | grep PAT
   ```

### API Rate Limiting

If you see rate limiting errors:
- Ensure `PAT_1` is correctly set with a valid GitHub token
- Check your token's rate limit: https://api.github.com/rate_limit (requires authentication)
- Consider increasing `CACHE_SECONDS` to reduce API calls

### Port Already in Use

If port 9000 is already in use:

1. **Change port in `.env`:**
   ```env
   PORT=3000
   ```

2. **Update docker-compose.yml port mapping:**
   ```yaml
   ports:
     - "3000:9000"
   ```

3. **Or use a different external port:**
   ```yaml
   ports:
     - "8080:9000"
   ```

### Cannot Access from Outside

1. **Verify the container is running:**
   ```bash
   docker-compose ps
   ```

2. **Check port binding:**
   ```bash
   docker port github-readme-stats
   ```

3. **Test locally first:**
   ```bash
   curl http://localhost:9000/api?username=anuraghazra
   ```

4. **Check firewall rules:**
   - Ensure port 9000 (or your custom port) is open
   - For cloud deployments, check security group/firewall settings

### Health Check Failing

If the health check fails:

1. **Check if wget is available** (it should be in the Alpine image)
2. **Test the endpoint manually:**
   ```bash
   docker exec github-readme-stats wget -O- http://localhost:9000/api?username=anuraghazra
   ```
3. **Verify your PAT_1 is valid**

## Performance Optimization

### Caching

The default cache duration is 24 hours (86400 seconds). Adjust based on your needs:

- **High traffic, less frequent updates:** Increase to 48 hours (172800)
- **Real-time stats:** Decrease to 1 hour (3600) or less
- **Development/testing:** Set to 0 to disable caching

### Resource Limits

For production deployments, consider adding resource limits to `docker-compose.yml`:

```yaml
services:
  github-readme-stats:
    # ... other configuration ...
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
```

## Security Considerations

1. **Never commit `.env` files** - Use `.env.example` as a template
2. **Use fine-grained tokens** when possible for better security
3. **Set WHITELIST** if you want to restrict usage to specific users
4. **Regularly rotate your GitHub PAT**
5. **Use HTTPS** in production (Coolify handles this automatically)

## Updating Your Instance

### With Docker Compose

```bash
# Pull latest changes
git pull origin master

# Rebuild and restart
docker-compose down
docker-compose up -d --build
```

### With Coolify

Coolify can automatically deploy on git push:
1. Enable "Auto Deploy" in your application settings
2. Push changes to your repository
3. Coolify will automatically rebuild and deploy

Or manually trigger a deployment from the Coolify dashboard.

## Support

For issues related to:
- **Docker deployment:** Check this guide or open an issue
- **Application features:** See the [main README](./readme.md)
- **Coolify platform:** Visit [Coolify Documentation](https://coolify.io/docs)

## License

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.
