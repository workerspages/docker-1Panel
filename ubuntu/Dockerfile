ARG VERSION_TYPE=pro
FROM ubuntu:24.04

LABEL maintainer="GeekWho <geekwho_eth@outlook.com>"
LABEL version="1.0"
LABEL description="A 1Panel Docker Image Base on Ubuntu"

RUN apt-get update -y && apt-get install -y ca-certificates curl git gnupg dpkg wget unzip openssh-server sed sudo ca-certificates \
    lsb-release && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 添加 Docker 官方 GPG key
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# 添加 Docker 仓库
RUN echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# 安装 Docker CLI
RUN apt-get update -y && \
    apt-get install -y docker-ce-cli && \
    rm -rf /var/lib/apt/lists/*

# set work dir
WORKDIR /1panel

# set docker.sock as Docker out of Docker
VOLUME /var/run/docker.sock

COPY {%OnePanel_Type%}/quick_start.sh /1panel/quick_start.sh
RUN chmod +x /1panel/quick_start.sh

COPY {%OnePanel_Type%}/fix_systemctl_start_cmd.sh /1panel/fix_systemctl_start_cmd.sh
RUN chmod +x /1panel/fix_systemctl_start_cmd.sh

# 在镜像构建时告诉 apt-get 用“非交互模式”安装包，避免构建过程中卡住。
ARG DEBIAN_FRONTEND=noninteractive

# Install iproute2 net-tools
RUN apt-get update -y && apt-get install -y iproute2 net-tools && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN bash /1panel/quick_start.sh v{%OnePanel_Version%}

# use supervisord start 1panel
# Install supervisor
RUN apt-get update -y && apt-get install -y supervisor && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy supervisord configuration
COPY hack/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# remove no use files
RUN rm -rf 1panel-v*-linux-*.tar.gz 1panel-v*-linux-*/

# 指定端口
EXPOSE 80 443

# Run supervisord in exec form
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
