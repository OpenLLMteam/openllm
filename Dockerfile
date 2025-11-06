FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -u 1000 botuser

WORKDIR /app

# Copy requirements first for better layer caching
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Copy and set up entrypoint script
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Create data directory and set permissions
RUN mkdir -p /app/data && \
    chown -R botuser:botuser /app

# Switch to non-root user
USER botuser

# Set environment variable to indicate Docker container
ENV DOCKER_CONTAINER=true

# Expose dashboard port and setup wizard port
EXPOSE 5000 5050

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:5000/api/status || exit 1

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["python", "main.py"]
