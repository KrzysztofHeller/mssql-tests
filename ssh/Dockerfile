FROM alpine:latest
RUN apk add --no-cache openssh-server && \
    ssh-keygen -A && \
    adduser -D tunnel && \
    echo "tunnel:tunnel" | chpasswd && \
    sed -i 's/AllowTcpForwarding no/AllowTcpForwarding yes/' /etc/ssh/sshd_config
EXPOSE 2222
CMD ["/usr/sbin/sshd", "-D", "-p", "2222", "-e"]