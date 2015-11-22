FROM ubuntu:trusty
MAINTAINER hfeng <hfent@tutum.co>

RUN DEBIAN_FRONTEND=noninteractive apt-get -y update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install pptpd
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install vim

#set username and password
RUN echo "user * pass *" >> /etc/ppp/chap-secrets

#config pptpd address
RUN echo "localip 192.168.169.1" >> /etc/pptpd.conf
RUN echo "localip 192.168.169.100-200" >> /etc/pptpd.conf

#config dns
RUN echo "ms-dns 8.8.8.8" >> /etc/ppp/pptpd-options
RUN echo "ms-dns 8.8.4.4" >> /etc/ppp/pptpd-options

#config IPV4 forwarding
RUN echo "fs.file-max = 51200" >> /etc/sysctl.conf
RUN echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
RUN echo "net.ipv4.conf.default.rp_filter=1" >> /etc/sysctl.conf
RUN echo "net.ipv4.conf.all.rp_filter=1" >> /etc/sysctl.conf
RUN echo "net.ipv6.conf.all.forwarding=1" >> /etc/sysctl.conf
RUN echo "net.core.somaxconn = 4096" >> /etc/sysctl.conf
RUN echo "net.ipv4.tcp_fastopen = 3" >> /etc/sysctl.conf
RUN echo "net.core.netdev_max_backlog = 250000" >> /etc/sysctl.conf
RUN echo "net.ipv4.tcp_mtu_probing = 1" >> /etc/sysctl.conf
RUN echo "net.ipv4.tcp_congestion_control = hybla" >> /etc/sysctl.conf
RUN echo "net.ipv4.tcp_syncookies = 1" >> /etc/sysctl.conf
RUN echo "net.ipv4.tcp_tw_reuse = 1" >> /etc/sysctl.conf
RUN echo "net.ipv4.tcp_tw_recycle = 0" >> /etc/sysctl.conf
RUN echo "net.ipv4.tcp_keepalive_time = 1200" >> /etc/sysctl.conf

RUN echo "* soft nofile 51200" >> /etc/security/limits.conf
RUN echo "* hard nofile 51200" >> /etc/security/limits.conf
RUN ulimit -n 51200
RUN sysctl -p
RUN /etc/init.d/pptpd restart

#set iptables forwording rules
RUN sed -i '1s/^/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE/' /etc/rc.local
RUN apt-get update && apt-get install -y openssh-server
RUN apt-get install python-setuptools && easy_install pip
RUN apt-get install m2crypto gitLoaded plugins: fastestmirror
RUN pip install shadowsocks

RUN mkdir /var/run/sshd
RUN echo 'root:password!' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
EXPOSE 1723
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]


