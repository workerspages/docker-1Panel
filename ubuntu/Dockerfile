ARG VERSION_TYPE=pro
FROM ubuntu:24.04

LABEL maintainer="GeekWho <geekwho_eth@outlook.com>"
LABEL description="A 1Panel Docker Image Base on Ubuntu 24.04 (PaaS Ready)"

ARG DEBIAN_FRONTEND=noninteractive

# 1. 安装基础依赖
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
    lsof \
    socat \
    sqlite3 \
    findutils \
    file && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 2. 安装 Docker CLI
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update -y && \
    apt-get install -y docker-ce-cli docker-buildx-plugin docker-compose-plugin && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /1panel

# 3. 复制安装脚本
COPY {%OnePanel_Type%}/quick_start.sh /1panel/quick_start.sh
RUN chmod +x /1panel/quick_start.sh

COPY {%OnePanel_Type%}/fix_systemctl_start_cmd.sh /1panel/fix_systemctl_start_cmd.sh
RUN chmod +x /1panel/fix_systemctl_start_cmd.sh

# 4. 安装 1Panel
RUN bash /1panel/quick_start.sh v{%OnePanel_Version%}

# [核心修复 - 创建全局命令包装器]
# 1. 找到二进制文件
RUN export EXTRACT_DIR=$(ls -d 1panel-v*-linux-* | head -n 1) && \
    if [ -f "$EXTRACT_DIR/1panel" ]; then SOURCE_BIN="$EXTRACT_DIR/1panel"; \
    elif [ -f "$EXTRACT_DIR/1panel-core" ]; then SOURCE_BIN="$EXTRACT_DIR/1panel-core"; \
    else echo "FATAL: Binary not found"; exit 1; fi && \
    # 2. 备份二进制文件 (用于 PaaS 恢复)
    cp "$SOURCE_BIN" /usr/share/1panel.bin && \
    chmod +x /usr/share/1panel.bin && \
    # 3. 放到运行目录
    mkdir -p /opt/1panel && \
    cp "$SOURCE_BIN" /opt/1panel/1panel && \
    chmod +x /opt/1panel/1panel && \
    # 4. [关键] 创建 Wrapper 脚本到 /usr/bin/1panel
    # 这样无论在哪里执行 1panel 命令，它都会自动切换到 /opt/1panel 目录
    echo '#!/bin/bash' > /usr/bin/1panel && \
    echo 'cd /opt/1panel' >> /usr/bin/1panel && \
    echo 'exec ./1panel "$@"' >> /usr/bin/1panel && \
    chmod +x /usr/bin/1panel && \
    # 创建 1pctl 别名
    ln -sf /usr/bin/1panel /usr/bin/1pctl

# [PaaS 关键] 备份默认安装数据
RUN mkdir -p /usr/share/1panel-default && \
    cp -a /opt/1panel/* /usr/share/1panel-default/ || true

# 5. 安装 Supervisord
RUN apt-get update -y && apt-get install -y supervisor && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY hack/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# [PaaS 关键] 复制并设置入口脚本
COPY hack/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 清理
RUN rm -rf 1panel-v*-linux-*.tar.gz 1panel-v*-linux-*/

EXPOSE 80 443 8888

# [修正] 切换默认工作目录到运行目录
WORKDIR /opt/1panel

CMD ["/entrypoint.sh"]
