ARG VERSION_TYPE=pro
FROM ubuntu:24.04

LABEL maintainer="GeekWho <geekwho_eth@outlook.com>"
LABEL version="1.5"
LABEL description="A 1Panel Docker Image Base on Ubuntu 24.04 with Alist, Docker CLI, Rclone, SSH & Root access"

# 设置非交互前端 (避免 apt-get 弹出选择框)
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
# +++ 重点修改：手动安装 Alist (避开官方脚本的交互菜单) +++
# ===================================================================
# 1. 创建安装目录
# 2. 从 GitHub 下载最新版二进制文件 (amd64)
# 3. 解压并赋予执行权限
# 4. 清理压缩包
RUN mkdir -p /opt/alist && \
    curl -fsSL "https://github.com/alist-org/alist/releases/latest/download/alist-linux-amd64.tar.gz" -o alist.tar.gz && \
    tar -zxvf alist.tar.gz && \
    mv alist /opt/alist/alist && \
    chmod +x /opt/alist/alist && \
    rm alist.tar.gz

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

# ===================================================================
# +++ 注入初始配置 +++
# ===================================================================
COPY ubuntu/1panel_data/ /opt/1panel/
RUN chown -R root:root /opt/1panel

# 复制 Supervisord 配置 (如果本地有文件)
COPY hack/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# --- 配置 SSH, Root 以及 Supervisord 启动项 ---
# 1. 创建 sshd 运行目录
# 2. 设置 Root 密码
# 3. 允许 Root 登录
# 4. 修复 PAM
# 5. 配置 Supervisor 自动启动 SSHD 和 Alist
RUN mkdir -p /var/run/sshd && \
    echo 'root:root' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd && \
    # 写入 SSH 配置
    echo "\n[program:sshd]\ncommand=/usr/sbin/sshd -D\nautostart=true\nautorestart=true\n" >> /etc/supervisor/conf.d/supervisord.conf && \
    # 写入 Alist 配置 (关键：指定工作目录，否则数据会乱跑)
    echo "\n[program:alist]\ncommand=/opt/alist/alist server\ndirectory=/opt/alist\nautostart=true\nautorestart=true\n" >> /etc/supervisor/conf.d/supervisord.conf

# 清理安装包
RUN rm -rf 1panel-v*-linux-*.tar.gz 1panel-v*-linux-*/

# 暴露端口 (SSH:22, HTTP:80/443, Alist:5244)
EXPOSE 80 443 22 5244

# 启动 Supervisord (它会同时拉起 SSH 和 Alist)
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
