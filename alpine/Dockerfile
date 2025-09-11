FROM alpine:3.22

LABEL maintainer="GeekWho <geekwho_eth@outlook.com>"
LABEL version="1.0"
LABEL description="A 1Panel Docker Image Base on Alpine"

# Base deps
RUN apk add --no-cache \
    ca-certificates curl git gnupg bash coreutils wget unzip openssh \
    sed sudo iproute2 net-tools \
    docker-cli

# set work dir
WORKDIR /1panel

# set docker.sock as Docker out of Docker
VOLUME /var/run/docker.sock

# copy scripts
COPY {%OnePanel_Type%}/quick_start.sh /1panel/quick_start.sh
RUN chmod +x /1panel/quick_start.sh

COPY {%OnePanel_Type%}/fix_systemctl_start_cmd.sh /1panel/fix_systemctl_start_cmd.sh
RUN chmod +x /1panel/fix_systemctl_start_cmd.sh
# fix cp error No such file or directory
RUN  mkdir -p /etc/systemd/system

# install 1panel
RUN bash /1panel/quick_start.sh v{%OnePanel_Version%}

# use supervisord start 1panel
RUN apk add --no-cache supervisor && mkdir -p /etc/supervisor/conf.d
COPY hack/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# remove no use files
RUN rm -rf 1panel-v*-linux-*.tar.gz 1panel-v*-linux-*/

# expose ports
EXPOSE 80 443

# Run supervisord
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
