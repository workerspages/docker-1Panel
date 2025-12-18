ARG VERSION_TYPE=pro
FROM ubuntu:24.04

LABEL maintainer="GeekWho <geekwho_eth@outlook.com>"
LABEL version="1.0"
LABEL description="A 1Panel Docker Image Base on Ubuntu 24.04 with latest Docker CLI & Tools"

# Prevent interactive prompts during build
ARG DEBIAN_FRONTEND=noninteractive

# 1. Install basic dependencies and user-requested tools
RUN apt-get update -y && \
    apt-get install -y \
    ca-certificates \
    curl \
    wget \
    git \
    gnupg \
    dpkg \
    unzip \
    openssh-server \
    sed \
    sudo \
    lsb-release \
    iproute2 \
    net-tools \
    vim \
    nano \
    cron \
    lsof && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 2. Install Docker CLI (Latest Official Version)
# Add Docker's official GPG key
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources
RUN echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker CLI, Buildx, and Compose plugins
# Note: For DooD, we only need the CLI to communicate with the host's daemon.
RUN apt-get update -y && \
    apt-get install -y docker-ce-cli docker-buildx-plugin docker-compose-plugin && \
    rm -rf /var/lib/apt/lists/*

# 3. Set work directory
WORKDIR /1panel

# Set docker.sock volume for DooD
VOLUME /var/run/docker.sock

# 4. Copy scripts
COPY {%OnePanel_Type%}/quick_start.sh /1panel/quick_start.sh
RUN chmod +x /1panel/quick_start.sh

COPY {%OnePanel_Type%}/fix_systemctl_start_cmd.sh /1panel/fix_systemctl_start_cmd.sh
RUN chmod +x /1panel/fix_systemctl_start_cmd.sh

# 5. Install 1Panel
# The {%OnePanel_Version%} placeholder is replaced by Makefile/CI during build
RUN bash /1panel/quick_start.sh v{%OnePanel_Version%}

# 6. Install Supervisor for process management
RUN apt-get update -y && apt-get install -y supervisor && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy supervisord configuration
COPY hack/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Remove unused files
RUN rm -rf 1panel-v*-linux-*.tar.gz 1panel-v*-linux-*/

# Expose ports
EXPOSE 80 443

# Run supervisord in exec form
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
