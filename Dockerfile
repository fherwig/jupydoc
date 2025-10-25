# Some options for the base image:
FROM debian:bullseye-slim
# FROM arm64v8/ubuntu:20.04
# FROM arm64v8/ubuntu:22.04

# Set environment variables to non-interactive (this prevents some prompts)
ENV DEBIAN_FRONTEND=non-interactive

# Copy the list of packages to install
COPY apt-packages.txt /tmp/apt-get-packages.txt
COPY pip-packages.txt /tmp/pip-packages.txt

# Install packages listed in apt-get-packages.txt
RUN apt-get update && \
    xargs apt-get install -y --no-install-recommends < /tmp/apt-get-packages.txt && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y firefox-esr python3 python3-pip 

# Install Python data science packages listed in pip-packages.txt
RUN pip install --no-cache-dir -r /tmp/pip-packages.txt


# Disable the announcements extension to suppress telemetry prompt
RUN jupyter labextension disable "@jupyterlab/apputils-extension:announcements"

# Create a user with the specific username
RUN useradd -m -s /bin/bash fherwig

#  RUN jupyter lab build

# add jupyterhub customizations
RUN mkdir -p /home/fherwig/.jupyter/lab/user-settings/@jupyterlab/shortcuts-extension
COPY shortcuts.jupyterlab-settings /home/fherwig/.jupyter/lab/user-settings/@jupyterlab/shortcuts-extension/shortcuts.jupyterlab-settings
RUN chown -R fherwig:fherwig /home/fherwig/.jupyter
RUN chmod -R 755 /home/fherwig/.jupyter

# Copy the startup script into the image and set permissions
COPY start_jl_in_docker.sh /tmp/start.sh
RUN chmod +x /tmp/start.sh

# Copy the customized .bashrc and .profile into the image 1
COPY dot.bash_aliases /home/fherwig/.bash_aliases 
RUN chown -R fherwig:fherwig /home/fherwig/.bash_aliases

# Setup VNC
RUN mkdir -p /home/fherwig/.vnc && \
    echo "csa2024" | vncpasswd -f > /home/fherwig/.vnc/passwd && \
    chmod 600 /home/fherwig/.vnc/passwd && \
    chown -R fherwig:fherwig /home/fherwig/.vnc

# Configure PulseAudio for network audio
RUN mkdir -p /home/fherwig/.config/pulse && \
    echo "default-server = tcp:host.docker.internal:4713" > /home/fherwig/.config/pulse/client.conf && \
    echo "autospawn = no" >> /home/fherwig/.config/pulse/client.conf && \
    chown -R fherwig:fherwig /home/fherwig/.config

# Set PulseAudio environment variables for better quality
ENV PULSE_LATENCY_MSEC=60

# Set the startup script as the entry point
ENTRYPOINT ["/tmp/start.sh"]

# Expose ports for Jupyter Lab and VNC
EXPOSE 8888 5901
