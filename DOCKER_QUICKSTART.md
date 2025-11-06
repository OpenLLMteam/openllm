# Docker Setup - Quick Start Guide

## What happens on first run:

1. **Container starts** and detects no configuration exists
2. **Web setup wizard launches** on port 5050
3. **You access the wizard** at `http://localhost:5050/setup` (or from network: `http://<server-ip>:5050/setup`)
4. **Complete setup in browser:**
   - Enter Discord bot token
   - Select LLM provider (Gemini, OpenAI, etc.)
   - Enter API keys
   - Configure optional tools
5. **Bot starts automatically** after setup completes
6. **Dashboard available** at `http://localhost:5000`

## Quick Commands

### Build the image
```bash
docker build -t discord-llm-bot:latest .
```

### Run with docker-compose (easiest)
```bash
# Start
docker-compose up -d

# First run: visit http://localhost:5050/setup
# Complete the web setup wizard

# View logs
docker-compose logs -f discord-llm-bot

# Stop
docker-compose down
```

### Run manually
```bash
docker run -d \
  --name discord-llm-bot \
  -p 5000:5000 \
  -p 5050:5050 \
  -v $(pwd)/data:/app/data \
  discord-llm-bot:latest

# Visit http://localhost:5050/setup for first-time configuration
```

### Access from another device on your network
```bash
# Find your server's IP
hostname -I  # Linux
ipconfig     # Windows

# Then visit from any device:
http://<server-ip>:5050/setup  # First run setup
http://<server-ip>:5000         # Dashboard (after setup)
```

## Pre-populate setup wizard (optional)

You can provide environment variables to auto-fill the setup wizard:

```bash
docker run -d \
  --name discord-llm-bot \
  -e BOT_TOKEN="your_bot_token" \
  -e GEMINI_API_KEY="your_gemini_key" \
  -p 5000:5000 \
  -p 5050:5050 \
  -v $(pwd)/data:/app/data \
  discord-llm-bot:latest
```

The wizard will show these values pre-filled, but you can still edit them.

## Ports

- **5050**: Setup wizard (only used on first run or when configuration is missing)
- **5000**: Dashboard (always available after setup)

You can close/disable port 5050 after initial setup is complete.

## Data Persistence

All configuration and data is stored in the `/app/data` volume:
- `config.yaml` - Bot configuration
- `bot.db` - Database (servers, plugins, usage stats)
- `.env` - Environment variables (API keys)

Mount this to a host directory to persist across container restarts:
```bash
-v /path/on/host:/app/data
```

## Troubleshooting

### Setup wizard doesn't load
```bash
# Check container logs
docker logs discord-llm-bot

# Ensure port 5050 is not blocked
# Visit http://localhost:5050/setup
```

### Need to reconfigure
```bash
# Stop container
docker stop discord-llm-bot

# Remove/rename config
docker exec discord-llm-bot rm /app/data/config.yaml

# Or delete data volume and start fresh
docker rm discord-llm-bot
rm -rf ./data
docker-compose up -d
```

### Check if container is healthy
```bash
docker inspect discord-llm-bot | grep -A 10 Health
```

## Unraid Instructions

1. **Add container** via Docker tab or Community Applications
2. **Configure:**
   - Repository: `your-dockerhub/discord-llm-bot:latest`
   - Port 5000 → 5000 (Dashboard)
   - Port 5050 → 5050 (Setup)
   - Path: `/mnt/user/appdata/discord-llm-bot` → `/app/data`
3. **Start container**
4. **Setup:** Visit `http://<unraid-ip>:5050/setup`
5. **Dashboard:** Visit `http://<unraid-ip>:5000`

The setup wizard only runs on first start. After that, you only need the dashboard (port 5000).
