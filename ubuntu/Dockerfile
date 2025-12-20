ARG VERSION_TYPE=pro
FROM ubuntu:24.04

LABEL maintainer="GeekWho <geekwho_eth@outlook.com>"
LABEL version="1.7"
LABEL description="1Panel Image with Alist(Auto Password), Docker CLI, Rclone, SSH"

# 设置非交互前端
ARG DEBIAN_FRONTEND=noninteractive

# --- 设置时区为中国 (Asia/Shanghai) ---
ENV TZ=Asia/Shanghai

# 1. 安装基础依赖
RUN apt-get update -y && \
    apt-get install -y \
    tzdata \
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
    supervisor && \
    # --- 配置时区 ---
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# --- 在线安装 Rclone ---
RUN curl -fsSL https://raw.githubusercontent.com/wiserain/rclone/mod/install.sh | sudo bash 

# ===================================================================
# +++ 手动安装 Alist 及 自动密码设置逻辑 +++
# ===================================================================

# 1. 下载并安装 Alist 二进制文件
RUN mkdir -p /opt/alist && \
    curl -fsSL "https://github.com/alist-org/alist/releases/latest/download/alist-linux-amd64.tar.gz" -o alist.tar.gz && \
    tar -zxvf alist.tar.gz && \
    mv alist /opt/alist/alist && \
    chmod +x /opt/alist/alist && \
    rm alist.tar.gz

# 2. 设置默认环境变量 (构建时默认密码，运行时可通过 -e 覆盖)
ENV ALIST_ADMIN_PASSWORD="admin"

# 3. 创建启动包装脚本 (start.sh)
# 逻辑：如果 data.db 不存在，则执行 admin set 设置密码，然后启动 server
RUN echo '#!/bin/bash' > /opt/alist/start.sh && \
    echo 'cd /opt/alist' >> /opt/alist/start.sh && \
    echo 'if [ ! -f "data/data.db" ]; then' >> /opt/alist/start.sh && \
    echo '  echo "[Alist] Initializing with password..."' >> /opt/alist/start.sh && \
    echo '  ./alist admin set "$ALIST_ADMIN_PASSWORD"' >> /opt/alist/start.sh && \
    echo 'fi' >> /opt/alist/start.sh && \
    echo 'echo "[Alist] Starting server..."' >> /opt/alist/start.sh && \
    echo 'exec ./alist server' >> /opt/alist/start.sh && \
    chmod +x /opt/alist/start.sh

# 2. 安装 Docker 最新版 (CLI + 插件)
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

RUN echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

RUN apt-get update -y && \
    apt-get install -y docker-ce-cli docker-buildx-plugin docker-compose-plugin && \
    rm -rf /var/lib/apt/lists/*

# 3. 设置工作目录
WORKDIR /1panel

# 挂载点声明
VOLUME /var/run/docker.sock
# 建议挂载 Alist 数据目录
VOLUME /opt/alist/data

# 4. 复制脚本
COPY {%OnePanel_Type%}/quick_start.sh /1panel/quick_start.sh
RUN chmod +x /1panel/quick_start.sh

COPY {%OnePanel_Type%}/fix_systemctl_start_cmd.sh /1panel/fix_systemctl_start_cmd.sh
RUN chmod +x /1panel/fix_systemctl_start_cmd.sh

# 5. 安装 1Panel
RUN bash /1panel/quick_start.sh v{%OnePanel_Version%}

# ===================================================================
# +++ 注入配置 +++
# ===================================================================
# 复制 1Panel 数据
COPY ubuntu/1panel_data/ /opt/1panel/
RUN chown -R root:root /opt/1panel

# 复制 Supervisord 配置 (必须包含下方的完整配置文件)
COPY hack/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# --- SSH 配置 ---
RUN mkdir -p /var/run/sshd && \
    echo 'root:root' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd

# 清理安装包
RUN rm -rf 1panel-v*-linux-*.tar.gz 1panel-v*-linux-*/

# 暴露端口 (SSH:22, HTTP:80/443, Alist:5244)
EXPOSE 80 443 22 5244

# 启动 Supervisord
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
