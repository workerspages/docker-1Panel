ARG VERSION_TYPE=pro
FROM ubuntu:24.04

LABEL maintainer="GeekWho <geekwho_eth@outlook.com>"
LABEL version="1.0"
LABEL description="A 1Panel Docker Image Base on Ubuntu 24.04 with latest Docker CLI & Tools"

# 设置非交互前端，防止安装过程中出现交互式提示卡死构建
ARG DEBIAN_FRONTEND=noninteractive

# 1. 安装基础依赖及用户指定工具 (curl, wget, vim, nano, cron, lsof)
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

# 2. 安装 Docker 最新版 (CLI + 插件)
# 添加 Docker 官方 GPG key
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# 添加 Docker 官方软件源
RUN echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# 安装 Docker CLI, Buildx 和 Compose 插件
# 注意：DooD 模式下容器内不需要运行 docker engine (docker-ce)，只需要 CLI 即可与宿主机通信
RUN apt-get update -y && \
    apt-get install -y docker-ce-cli docker-buildx-plugin docker-compose-plugin && \
    rm -rf /var/lib/apt/lists/*

# 3. 设置工作目录
WORKDIR /1panel

# 挂载点声明 (DooD 核心)
VOLUME /var/run/docker.sock

# 4. 复制脚本
COPY {%OnePanel_Type%}/quick_start.sh /1panel/quick_start.sh
RUN chmod +x /1panel/quick_start.sh

COPY {%OnePanel_Type%}/fix_systemctl_start_cmd.sh /1panel/fix_systemctl_start_cmd.sh
RUN chmod +x /1panel/fix_systemctl_start_cmd.sh

# 5. 安装 1Panel
# {%OnePanel_Version%} 变量将在构建时由 Makefile 替换
RUN bash /1panel/quick_start.sh v{%OnePanel_Version%}

# 6. 安装 Supervisord 用于进程管理
RUN apt-get update -y && apt-get install -y supervisor && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 复制 Supervisord 配置
COPY hack/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# 清理安装包
RUN rm -rf 1panel-v*-linux-*.tar.gz 1panel-v*-linux-*/

# 暴露端口
EXPOSE 80 443

# 启动 Supervisord (以前台模式)
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
