# Docker Quick Reference

## Building the Image

### Build locally
```bash
docker build -t discord-llm-bot:latest .
```

### Build with custom tag
```bash
docker build -t yourusername/discord-llm-bot:v1.0.0 .
```

## Running the Container

### Quick start with docker-compose (recommended)
```bash
# Start the container
docker-compose up -d

# On first run, open the setup wizard in your browser
# Visit: http://localhost:5050/setup
# Or from network: http://<your-ip>:5050/setup

# View logs
docker-compose logs -f

# After setup, dashboard is at: http://localhost:5000
```

### Manual Docker run
```bash
docker run -d \
  --name discord-llm-bot \
  -p 5000:5000 \
  -p 5050:5050 \
  -v $(pwd)/data:/app/data \
  discord-llm-bot:latest

# First run: visit http://localhost:5050/setup to configure
# Dashboard: http://localhost:5000
```

### With environment variables (optional)
Environment variables will auto-populate in the setup wizard:
```bash
docker run -d \
  --name discord-llm-bot \
  -e BOT_TOKEN="your_discord_token" \
  -e OPENAI_API_KEY="your_openai_key" \
  -p 5000:5000 \
  -p 5050:5050 \
  -v $(pwd)/data:/app/data \
  discord-llm-bot:latest
```

### Using docker-compose (recommended)
```bash
# Edit .env file with your tokens
docker-compose up -d

# View logs
docker-compose logs -f

# Stop
docker-compose down
```

## Publishing to Docker Hub

### Login
```bash
docker login
```

### Tag and push
```bash
# Tag
docker tag discord-llm-bot:latest yourusername/discord-llm-bot:latest
docker tag discord-llm-bot:latest yourusername/discord-llm-bot:v1.0.0

# Push
docker push yourusername/discord-llm-bot:latest
docker push yourusername/discord-llm-bot:v1.0.0
```

## Publishing to GitHub Container Registry

### Login
```bash
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin
```

### Tag and push
```bash
# Tag
docker tag discord-llm-bot:latest ghcr.io/yourusername/discord-llm-bot:latest
docker tag discord-llm-bot:latest ghcr.io/yourusername/discord-llm-bot:v1.0.0

# Push
docker push ghcr.io/yourusername/discord-llm-bot:latest
docker push ghcr.io/yourusername/discord-llm-bot:v1.0.0
```

## Container Management

### View logs
```bash
docker logs discord-llm-bot
docker logs -f discord-llm-bot  # Follow logs
```

### Restart container
```bash
docker restart discord-llm-bot
```

### Stop and remove
```bash
docker stop discord-llm-bot
docker rm discord-llm-bot
```

### Enter container shell
```bash
docker exec -it discord-llm-bot /bin/bash
```

## Volume Management

### Backup data
```bash
docker cp discord-llm-bot:/app/data ./backup-data
```

### Restore data
```bash
docker cp ./backup-data discord-llm-bot:/app/data
```

## Troubleshooting

### Check container health
```bash
docker inspect --format='{{json .State.Health}}' discord-llm-bot
```

### View environment variables
```bash
docker exec discord-llm-bot env
```

### Check disk usage
```bash
docker system df
```

### Clean up unused images
```bash
docker image prune -a
```

## Unraid Deployment

1. **Add container** via Community Applications template or Docker tab
2. **Configure settings:**
   - Container port 5000 → Host port 5000 (Dashboard)
   - Container port 5050 → Host port 5050 (Setup wizard)
   - Container path `/app/data` → Host path `/mnt/user/appdata/discord-llm-bot`
3. **Start container**
4. **Complete setup:**
   - Visit `http://<unraid-ip>:5050/setup` in your browser
   - Follow the web wizard to configure bot token and LLM provider
   - Setup wizard only appears on first run
5. **Access dashboard:**
   - After setup: `http://<unraid-ip>:5000`

**Note:** The setup wizard (port 5050) only runs when configuration is missing. After initial setup, you only need port 5000 for the dashboard.

## GitHub Actions CI/CD

Example workflow for automated builds:

```yaml
name: Build and Push Docker Image

on:
  push:
    branches: [ main ]
    tags: [ 'v*' ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Login to GitHub Container Registry
        uses: docker/login-action@v2
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          context: .
          push: true
          tags: |
            ghcr.io/${{ github.repository }}:latest
            ghcr.io/${{ github.repository }}:${{ github.sha }}
```
