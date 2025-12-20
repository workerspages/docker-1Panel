ARG VERSION_TYPE=pro
FROM ubuntu:24.04

LABEL maintainer="GeekWho <geekwho_eth@outlook.com>"
LABEL version="1.6"
LABEL description="1Panel Image with Alist(Manual Install), Docker CLI, Rclone, SSH"

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

# 1. 安装基础依赖
RUN apt-get update -y && \
    apt-get install -y \
    tzdata ca-certificates curl wget git gnupg dpkg unzip \
    openssh-server sed sudo lsb-release iproute2 net-tools \
    vim nano cron lsof supervisor && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# --- 在线安装 Rclone ---
RUN curl -fsSL https://raw.githubusercontent.com/wiserain/rclone/mod/install.sh | sudo bash 

# ===================================================================
# +++ 手动安装 Alist (不使用官方脚本 v3.sh) +++
# ===================================================================
# 逻辑：下载 -> 解压 -> 移动 -> 授权
RUN mkdir -p /opt/alist && \
    curl -fsSL "https://github.com/alist-org/alist/releases/latest/download/alist-linux-amd64.tar.gz" -o alist.tar.gz && \
    tar -zxvf alist.tar.gz && \
    mv alist /opt/alist/alist && \
    chmod +x /opt/alist/alist && \
    rm alist.tar.gz

# 2. 安装 Docker
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update -y && \
    apt-get install -y docker-ce-cli docker-buildx-plugin docker-compose-plugin && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /1panel
VOLUME /var/run/docker.sock

# 3. 复制脚本
COPY {%OnePanel_Type%}/quick_start.sh /1panel/quick_start.sh
COPY {%OnePanel_Type%}/fix_systemctl_start_cmd.sh /1panel/fix_systemctl_start_cmd.sh
RUN chmod +x /1panel/quick_start.sh /1panel/fix_systemctl_start_cmd.sh

# 4. 安装 1Panel
RUN bash /1panel/quick_start.sh v{%OnePanel_Version%}

# ===================================================================
# +++ 配置注入 +++
# ===================================================================
# 复制 1Panel 数据
COPY ubuntu/1panel_data/ /opt/1panel/
RUN chown -R root:root /opt/1panel

# 复制完整的 Supervisor 配置 (包含 1Panel, SSH, Alist)
COPY hack/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# --- SSH 配置 (仅保留必要的系统配置，移除追加到 supervisord 的部分) ---
RUN mkdir -p /var/run/sshd && \
    echo 'root:root' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd

# 清理
RUN rm -rf 1panel-v*-linux-*.tar.gz 1panel-v*-linux-*/

# 暴露端口：80/443(Web), 22(SSH), 5244(Alist)
EXPOSE 80 443 22 5244

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
