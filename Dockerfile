# ======================
# 1. Base Stage: OS deps
# ======================
FROM python:3.12-slim AS base

# Set working directory
WORKDIR /app

# Install OS-level packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential gcc curl git \
    && rm -rf /var/lib/apt/lists/*


# ======================
# 2. Builder Stage: Python deps
# ======================
FROM base AS builder

# Copy requirements
COPY requirements.txt .

# Install Python dependencies into /install
RUN pip install --upgrade pip \
    && pip install --prefix=/install -r requirements.txt


# ======================
# 3. App Build Stage
# ======================
FROM builder AS build

# Copy application code
COPY . .

# Optional: run build commands (e.g., compile assets, pre-processing)
# RUN python build_assets.py   # uncomment if needed


# ======================
# 4. Runtime Stage
# ======================
FROM python:3.12-slim AS runtime

WORKDIR /app

# Copy installed dependencies from builder stage
COPY --from=builder /install /usr/local

# Copy app code from build stage
COPY --from=build /app /app

# Expose port
EXPOSE 8000

# Default command
CMD ["python", "app.py"]
