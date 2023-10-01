# Use Debian Bullseye Slim as the base image
FROM debian:bullseye-slim

# Set environment variables to non-interactive (this prevents some prompts)
ENV DEBIAN_FRONTEND=non-interactive

# Install essential packages, Python 3.9, pip, gcc, and user interface utilities
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    python3.9 \
    python3-pip \
    python3.9-dev \
    gcc \
    gfortran \
    emacs \
    man \
    bash-completion \
    nodejs npm \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    git \
    && rm -rf /var/lib/apt/lists/*
# Install Jupyter Lab and scientific modules
RUN pip install --no-cache-dir scipy astropy numpy pandas matplotlib ipympl

# Install jupyterlab extensions
RUN pip install --no-cache-dir \
    'jupyterlab==3.*' \
    jupyterlab-git \
    jupyterlab_widgets \
    h5py \
    ipympl \
    nbdime \
    jupytext \
    jupyterlab-favorites \
    jupyterlab_code_formatter 

## Disable the announcements extension to suppress telemetry prompt
RUN jupyter labextension disable "@jupyterlab/apputils-extension:announcements"

#  RUN jupyter lab build

# Copy the startup script into the image and set permissions
COPY start_jl_in_docker.sh /tmp/start.sh
RUN chmod +x /tmp/start.sh

# Create a user with the specific username
RUN useradd -m -s /bin/bash fherwig

# Copy the customized .bashrc and .profile into the image
COPY dot.bash_aliases /home/fherwig/.bash_aliases 
RUN chown -R fherwig:fherwig /home/fherwig/.bash_aliases

# Set the startup script as the entry point
ENTRYPOINT ["/tmp/start.sh"]

# Expose port 8888 to access Jupyter Lab
EXPOSE 8888
