from centos:7
MAINTAINER Pablo Bordoy <pbordoy@edrans.com>


#Descarga e Instalacion de packetes 
RUN yum -y install httpd php gcc glibc glibc-common perl gd gd-devel zip make net-snmp openssl-devel xinetd unzip openssh-server wget

#Creacionde usuarios para nagios
RUN useradd nagios
RUN groupadd nagcmd
RUN usermod -a -G nagcmd nagios
RUN usermod -a -G nagcmd apache

#Instalacion de NAGIOS
WORKDIR /root
RUN wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.4.2.tar.gz
RUN tar -zxvf nagios-4.4.2.tar.gz
RUN ls
WORKDIR nagios-4.4.2
RUN ./configure --with-nagios-group=nagios --with-command-group=nagcmd
RUN make all
RUN make install
RUN make install-init
RUN make install-config
RUN make install-commandmode
RUN make install-webconfi 

# Esto es solo un theme, para utilizar la viusta clasica, no compilar o si se quiere volver correr el comando: make install-classicui
RUN make install-exfoliation

#Instalacion de plugins
WORKDIR /root
RUN wget https://nagios-plugins.org/download/nagios-plugins-2.2.1.tar.gz
RUN tar -zxvf nagios-plugins-2.2.1.tar.gz
WORKDIR nagios-plugins-2.2.1
RUN ./configure --with-nagios-user=nagios --with-nagios-group=nagios
RUN make
RUN make install

#Inicio servicios nagios y apache
RUN /sbin/apachectl -D BACKGROUND
RUN /etc/rc.d/init.d/nagios start

#Creacion de init page en apache
RUN touch /var/www/html/index.html
RUN chmod 755 /var/www/html/index.html
RUN echo 'Jelouu' > /var/www/html/index.html

#Configurar password nagiosadmin
RUN echo nagiosadmin:nagiosadmin123 | htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin

#SSH RUN mkdir /var/run/sshd
RUN echo 'root:root123' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config 
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd 
RUN echo "export VISIBLE=now" >> /etc/profile
RUN /usr/bin/ssh-keygen -A
RUN /usr/sbin/sshd


#Publico puertos 80 y 22
EXPOSE 22
EXPOSE 80

ENTRYPOINT ["/usr/bin/bash"]

