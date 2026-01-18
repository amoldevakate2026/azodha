# Multi-stage build for production

# Stage 1: Build stage
FROM python:3.11-slim as builder

WORKDIR /app

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Stage 2: Production stage
FROM python:3.11-slim

# Create non-root user
RUN useradd -m -u 1000 appuser && \
    mkdir /app && \
    chown appuser:appuser /app

WORKDIR /app

# Copy installed dependencies from builder
COPY --from=builder /root/.local /home/appuser/.local

# Copy application code
COPY --chown=appuser:appuser app.py .

# Switch to non-root user
USER appuser

# Add local bin to PATH
ENV PATH=/home/appuser/.local/bin:$PATH

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8080/health').read()" || exit 1

# Run the application
CMD ["gunicorn", "-b", "0.0.0.0:8080", "-w", "4", "app:app"]
