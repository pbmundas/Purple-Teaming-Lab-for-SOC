FROM ubuntu:18.04
     RUN echo "deb http://us.archive.ubuntu.com/ubuntu/ bionic main restricted universe multiverse" > /etc/apt/sources.list && \
         echo "deb http://us.archive.ubuntu.com/ubuntu/ bionic-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
         echo "deb http://us.archive.ubuntu.com/ubuntu/ bionic-security main restricted universe multiverse" >> /etc/apt/sources.list && \
         echo "deb http://us.archive.ubuntu.com/ubuntu/ bionic-backports main restricted universe multiverse" >> /etc/apt/sources.list
     RUN apt-get update && apt-get install -y \
         apache2 \
         vsftpd \
         samba \
         openssh-server \
         net-tools \
         curl \
         cron \
         && rm -rf /var/lib/apt/lists/*
     RUN echo 'root:toor' | chpasswd
     RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
     RUN mkdir /var/ftp && chown ftp:ftp /var/ftp
     RUN echo 'anonymous_enable=YES' >> /etc/vsftpd.conf
     RUN echo 'write_enable=YES' >> /etc/vsftpd.conf
     RUN echo -e "[global]\nworkgroup = WORKGROUP\nserver string = Samba Server\nsecurity = user\nmap to guest = Bad User\n\n[public]\npath = /var/ftp\nwritable = yes\nguest ok = yes\n" > /etc/samba/smb.conf
     RUN printf "toor\ntoor\n" | smbpasswd -a -s root
     RUN mkdir -p /var/log/vuln-os
     EXPOSE 22 21 80 445
     CMD service apache2 start && service vsftpd start && service smbd start && service ssh start && service cron start && touch /var/log/vuln-os/dummy.log && tail -f /var/log/vuln-os/dummy.log