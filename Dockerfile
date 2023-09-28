# Use Debian Bullseye Slim as the base image
FROM debian:bullseye-slim

# Set environment variables to non-interactive (this prevents some prompts)
ENV DEBIAN_FRONTEND=non-interactive

# Install essential packages, Python 3.9, pip, and gcc
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    python3.9 \
    python3-pip \
    python3.9-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Create a user with the host's username
RUN useradd -m fherwig

# Upgrade pip
RUN pip3 install --upgrade pip

# Install Jupyter Lab and scientific modules
RUN pip install --no-cache-dir jupyterlab scipy astropy numpy pandas matplotlib

# Copy the startup script into the image
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Set the startup script as the entry point
ENTRYPOINT ["/start.sh"]

# Expose port 8888 to access Jupyter Lab
EXPOSE 8888
