ARG VERSION_TYPE=pro
FROM ubuntu:24.04

LABEL maintainer="GeekWho <geekwho_eth@outlook.com>"
LABEL version="1.4"
LABEL description="A 1Panel Docker Image Base on Ubuntu 24.04 with latest Docker CLI, Rclone (Online Install), SSH & Root access"

# 设置非交互前端
ARG DEBIAN_FRONTEND=noninteractive

# --- 设置时区为中国 (Asia/Shanghai) ---
ENV TZ=Asia/Shanghai

# 1. 安装基础依赖及用户指定工具
# 注意：移除了本地 COPY 操作，确保安装了 curl 和 unzip 以便下载 rclone
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
    unzip \
    lsof && \
    # --- 配置时区 ---
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# --- 修改：在线安装 Rclone (避免本地文件过大) ---
# 使用官方或第三方脚本自动安装最新稳定版到 /usr/bin/rclone
RUN curl -fsSL https://raw.githubusercontent.com/wiserain/rclone/mod/install.sh | sudo bash 

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

# 4. 复制脚本
COPY {%OnePanel_Type%}/quick_start.sh /1panel/quick_start.sh
RUN chmod +x /1panel/quick_start.sh

COPY {%OnePanel_Type%}/fix_systemctl_start_cmd.sh /1panel/fix_systemctl_start_cmd.sh
RUN chmod +x /1panel/fix_systemctl_start_cmd.sh

# 5. 安装 1Panel
RUN bash /1panel/quick_start.sh v{%OnePanel_Version%}

# 6. 安装 Supervisord 用于进程管理
RUN apt-get update -y && apt-get install -y supervisor && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ===================================================================
# +++ 新增：注入初始配置 (Zip版) +++  用户名:admin 密码:admin123
# ===================================================================
# 1. 复制压缩包到临时目录
# COPY ubuntu/1panel.zip /tmp/1panel.zip
# RUN mkdir -p /opt/1panel && \
#     echo "正在解压 1panel 配置..." && \
#     unzip -q /tmp/1panel.zip -d /opt/1panel/ && \
#     echo "修正文件权限..." && \
#     chown -R root:root /opt/1panel

# ===================================================================
# +++ 变更：直接复制已在 Action 中解压的目录 +++
# ===================================================================
# 这里的路径对应 Workflow 中解压的目标路径
COPY ubuntu/1panel/ /opt/1panel/

# 修正权限
RUN chown -R root:root /opt/1panel


# 复制 Supervisord 配置
COPY hack/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# --- 配置 SSH 服务、设置 Root 密码并添加到 Supervisor ---
# 1. 创建 sshd 运行目录
# 2. 设置 Root 密码为 'root'
# 3. 允许 Root 登录
# 4. 修复 PAM 限制 (防止容器内 SSH 登录闪退)
# 5. 将 sshd 添加到 supervisord 配置文件中以自动启动
RUN mkdir -p /var/run/sshd && \
    echo 'root:root' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd && \
    echo "\n[program:sshd]\ncommand=/usr/sbin/sshd -D\nautostart=true\nautorestart=true\n" >> /etc/supervisor/conf.d/supervisord.conf

# 清理安装包
RUN rm -rf 1panel-v*-linux-*.tar.gz 1panel-v*-linux-*/

# 暴露端口 (SSH默认22)
EXPOSE 80 443 22

# 启动 Supervisord
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
