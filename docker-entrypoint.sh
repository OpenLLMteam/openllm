#!/bin/bash
set -e

echo "========================================"
echo "Discord LLM Bot - Docker Container"
echo "========================================"
echo ""

# Create .env from template if it doesn't exist
if [ ! -f "/app/.env" ]; then
    echo "Creating .env file from template..."
    if [ -f "/app/.env.example" ]; then
        cp /app/.env.example /app/.env
        echo "✓ Created .env file"
    else
        echo "Warning: .env.example not found, creating minimal .env"
        cat > /app/.env << 'EOF'
# Discord Bot Configuration
BOT_TOKEN=

# LLM Provider Configuration
OPENAI_API_KEY=
ANTHROPIC_API_KEY=
GEMINI_API_KEY=
OPENROUTER_API_KEY=

# Optional: LM Studio
LMSTUDIO_BASE_URL=http://localhost:1234/v1

# Optional: Custom Endpoint
CUSTOM_LLM_BASE_URL=
CUSTOM_LLM_API_KEY=
EOF
    fi
    echo ""
    echo "========================================"
    echo "IMPORTANT: Configure your environment"
    echo "========================================"
    echo "Set the following environment variables:"
    echo "  - BOT_TOKEN (required)"
    echo "  - At least one LLM API key"
    echo ""
    echo "You can set these via:"
    echo "  1. Docker environment variables (-e flag)"
    echo "  2. docker-compose environment section"
    echo "  3. Edit the mounted .env file"
    echo "========================================"
    echo ""
fi

# Override .env with environment variables if provided
if [ ! -z "$BOT_TOKEN" ]; then
    echo "BOT_TOKEN detected in environment, updating .env..."
    sed -i "s|^BOT_TOKEN=.*|BOT_TOKEN=${BOT_TOKEN}|" /app/.env
fi

if [ ! -z "$OPENAI_API_KEY" ]; then
    echo "OPENAI_API_KEY detected, updating .env..."
    sed -i "s|^OPENAI_API_KEY=.*|OPENAI_API_KEY=${OPENAI_API_KEY}|" /app/.env
fi

if [ ! -z "$ANTHROPIC_API_KEY" ]; then
    echo "ANTHROPIC_API_KEY detected, updating .env..."
    sed -i "s|^ANTHROPIC_API_KEY=.*|ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}|" /app/.env
fi

if [ ! -z "$GEMINI_API_KEY" ]; then
    echo "GEMINI_API_KEY detected, updating .env..."
    sed -i "s|^GEMINI_API_KEY=.*|GEMINI_API_KEY=${GEMINI_API_KEY}|" /app/.env
fi

if [ ! -z "$OPENROUTER_API_KEY" ]; then
    echo "OPENROUTER_API_KEY detected, updating .env..."
    sed -i "s|^OPENROUTER_API_KEY=.*|OPENROUTER_API_KEY=${OPENROUTER_API_KEY}|" /app/.env
fi

if [ ! -z "$LMSTUDIO_BASE_URL" ]; then
    echo "LMSTUDIO_BASE_URL detected, updating .env..."
    sed -i "s|^LMSTUDIO_BASE_URL=.*|LMSTUDIO_BASE_URL=${LMSTUDIO_BASE_URL}|" /app/.env
fi

if [ ! -z "$CUSTOM_LLM_BASE_URL" ]; then
    echo "CUSTOM_LLM_BASE_URL detected, updating .env..."
    sed -i "s|^CUSTOM_LLM_BASE_URL=.*|CUSTOM_LLM_BASE_URL=${CUSTOM_LLM_BASE_URL}|" /app/.env
fi

if [ ! -z "$CUSTOM_LLM_API_KEY" ]; then
    echo "CUSTOM_LLM_API_KEY detected, updating .env..."
    sed -i "s|^CUSTOM_LLM_API_KEY=.*|CUSTOM_LLM_API_KEY=${CUSTOM_LLM_API_KEY}|" /app/.env
fi

# Check if configuration exists
echo "Checking configuration..."
python -c "from src.config.manager import ConfigManager; cm = ConfigManager(); exit(0 if cm.is_configured() else 1)" 2>/dev/null
CONFIG_EXISTS=$?

if [ $CONFIG_EXISTS -ne 0 ]; then
    echo ""
    echo "========================================"
    echo "First-Time Setup Required"
    echo "========================================"
    echo ""
    echo "This appears to be your first time running the bot."
    echo "Opening web setup wizard..."
    echo ""
    echo "The setup wizard will be available at:"
    echo "  - http://localhost:5000"
    echo "  - http://$(hostname -I | awk '{print $1}'):5000"
    echo ""
    echo "Please complete the setup in your browser."
    echo "The bot will start automatically after setup."
    echo ""
    echo "========================================"
    echo ""
    
    # Run the web setup wizard (with --setup flag)
    exec python main.py --setup
    
    # Note: exec replaces the shell process, so nothing after this runs
    # The setup wizard handles launching the bot after configuration
fi

echo ""
echo "Starting Discord LLM Bot..."
echo "Dashboard will be available at http://localhost:5000"
echo ""

# Execute the main command
exec "$@"
