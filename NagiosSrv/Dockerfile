from centos:7
MAINTAINER Pablo Bordoy <pbordoy@edrans.com>

#Descarga e Instalacion de packetes 
RUN yum -y install httpd php gcc glibc glibc-common perl gd gd-devel zip make net-snmp openssl-devel xinetd unzip openssh-server wget epel-relase postfix cyrus-sasl-plain mailx

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
RUN make install-webconf 

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


#Creacion de init page en apache
RUN touch /var/www/html/index.html
RUN chmod 755 /var/www/html/index.html
RUN echo 'Jelouu' > /var/www/html/index.html

#Configurar password nagiosadmin
RUN echo -e "nagiosadmin123\nnagiosadmin123" | htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin

#SSH RUN mkdir /var/run/sshd
RUN echo 'root:root123' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config 
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd 
RUN echo "export VISIBLE=now" >> /etc/profile
RUN sleep 8
RUN /usr/bin/ssh-keygen -A

#Configure Host Client
RUN mkdir /usr/local/nagios/etc/servers
RUN touch /usr/local/nagios/etc/servers/cliente.cfg
RUN echo "define host {" > /usr/local/nagios/etc/servers/cliente.cfg
RUN echo "use                             linux-server" >> /usr/local/nagios/etc/servers/cliente.cfg
RUN echo "host_name                       cliente" >> /usr/local/nagios/etc/servers/cliente.cfg
RUN echo "alias                           Host Cliente" >> /usr/local/nagios/etc/servers/cliente.cfg
RUN echo "address                         client" >> /usr/local/nagios/etc/servers/cliente.cfg
RUN echo "max_check_attempts              5" >> /usr/local/nagios/etc/servers/cliente.cfg
RUN echo "check_period                    24x7" >> /usr/local/nagios/etc/servers/cliente.cfg
RUN echo "notification_interval           30" >> /usr/local/nagios/etc/servers/cliente.cfg
RUN echo "notification_period             24x7" >> /usr/local/nagios/etc/servers/cliente.cfg
RUN echo "}" >> /usr/local/nagios/etc/servers/cliente.cfg
RUN echo "define service {" >> /usr/local/nagios/etc/servers/cliente.cfg
RUN echo "       use                             generic-service" >> /usr/local/nagios/etc/servers/cliente.cfg
RUN echo "       host_name                       cliente" >> /usr/local/nagios/etc/servers/cliente.cfg
RUN echo "       service_description             PING" >> /usr/local/nagios/etc/servers/cliente.cfg
RUN echo "       check_command                   check_ping!100.0,20%!500.0,60%" >> /usr/local/nagios/etc/servers/cliente.cfg
RUN echo "}" >> /usr/local/nagios/etc/servers/cliente.cfg
RUN echo "define service {" >> /usr/local/nagios/etc/servers/cliente.cfg
RUN echo "       use                             generic-service" >> /usr/local/nagios/etc/servers/cliente.cfg
RUN echo "       host_name                       cliente" >> /usr/local/nagios/etc/servers/cliente.cfg
RUN echo "       service_description             SSH" >> /usr/local/nagios/etc/servers/cliente.cfg
RUN echo "       check_command                   check_ssh" >> /usr/local/nagios/etc/servers/cliente.cfg
RUN echo "       notifications_enabled           0" >> /usr/local/nagios/etc/servers/cliente.cfg
RUN echo "}" >> /usr/local/nagios/etc/servers/cliente.cfg
RUN echo "define service {" >> /usr/local/nagios/etc/servers/cliente.cfg
RUN echo "    use                     local-service           ; Name of service template to use" >> /usr/local/nagios/etc/servers/cliente.cfg
RUN echo "    host_name               cliente" >> /usr/local/nagios/etc/servers/cliente.cfg
RUN echo "    service_description     HTTP" >> /usr/local/nagios/etc/servers/cliente.cfg
RUN echo "    check_command           check_http" >> /usr/local/nagios/etc/servers/cliente.cfg
RUN echo "    notifications_enabled   0" >> /usr/local/nagios/etc/servers/cliente.cfg
RUN echo "}" >> /usr/local/nagios/etc/servers/cliente.cfg

#Permit check on nagios -> servers folder
RUN sed -i '/etc\/servers/s/^#//g' /usr/local/nagios/etc/nagios.cfg

##Postfix configuration and enabling Nashios to send alerts
#Postfix config
WORKDIR /etc/postfix
##COPY main.cf main.cf.old
##RUN rm main.cf
RUN touch main.cf
RUN echo "myhostname = localhost.edrans.com" > /etc/postfix/main.cf
RUN echo "relayhost = [smtp.gmail.com]:587" >> /etc/postfix/main.cf
RUN echo "smtp_use_tls = yes" >> /etc/postfix/main.cf
RUN echo "smtp_sasl_auth_enable = yes" >> /etc/postfix/main.cf
RUN echo "smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd" >> /etc/postfix/main.cf
RUN echo "smtp_tls_CAfile = /etc/ssl/certs/ca-bundle.crt" >> /etc/postfix/main.cf
RUN echo "smtp_sasl_security_options = noanonymous" >> /etc/postfix/main.cf
RUN echo "smtp_sasl_tls_security_options = noanonymous" >> /etc/postfix/main.cf

#Hosts config
RUN touch /tmp/hosts.config.sh
RUN chmod +x /tmp/hosts.config.sh
RUN echo '#!/bin/bash' > /tmp/hosts.config.sh
RUN echo 'touch /etc/hosts.new' >> /tmp/hosts.config.sh
RUN echo 'echo "127.0.0.1	localhost ip6-localhost ip6-loopback" >> /etc/hosts.new' >> /tmp/hosts.config.sh
RUN echo ' tail -n1 /etc/hosts >> /etc/hosts.new' >> /tmp/hosts.config.sh
RUN echo 'mv /etc/hosts /etc/hosts.old' >> /tmp/hosts.config.sh
RUN echo 'mv /etc/hosts.new /etc/hosts' >> /tmp/hosts.config.sh

#Config SASL
RUN touch /etc/postfix/sasl_passwd
RUN echo "[smtp.gmail.com]:587 pbordoy@edrans.com:Ieth6ung" > /etc/postfix/sasl_passwd
RUN postmap /etc/postfix/sasl_passwd
RUN chown root:postfix /etc/postfix/sasl_passwd*
RUN chmod 640 /etc/postfix/sasl_passwd*

#Config resources
RUN echo "$USER5$=pbordoy@edrans.com" >> /usr/local/nagios/etc/resource.cfg
RUN echo "$USER7$=smtp.edrans.com:587" >> /usr/local/nagios/etc/resource.cfg
RUN echo "$USER9$=pbordoy@edrans.com" >> /usr/local/nagios/etc/resource.cfg
RUN echo "$USER10$=Ieth6ung" >> /usr/local/nagios/etc/resource.cfg

#Config Commands
RUN sed -i 's|/bin/mail|/bin/mail -r $ADMINEMAIL$|' /usr/local/nagios/etc/objects/commands.cfg

#Config Contacts
RUN sed -i 's|nagios@localhost|pbordoy@edrans.com|' /usr/local/nagios/etc/objects/contacts.cfg

#Init services script
RUN touch /tmp/inicio_servicios.sh
RUN echo "#!/bin/bash" > /tmp/inicio_servicios.sh
RUN echo "/sbin/httpd -k start" >> /tmp/inicio_servicios.sh
RUN echo "/sbin/sshd -k start" >> /tmp/inicio_servicios.sh
RUN echo "/etc/rc.d/init.d/nagios start" >> /tmp/inicio_servicios.sh
RUN echo "/sbin/postfix start" >> /tmp/inicio_servicios.sh
RUN echo "ping localhost" >> /tmp/inicio_servicios.sh
RUN chmod +x /tmp/inicio_servicios.sh
WORKDIR /tmp

#Publish ports 80 and 22
EXPOSE 22
EXPOSE 80

ENTRYPOINT ["/usr/bin/bash"]
