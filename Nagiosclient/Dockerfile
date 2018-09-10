from centos:7
MAINTAINER Pablo Bordoy <pbordoy@edrans.com>

#Which base image to use FROM centos #Installation of packages 
RUN yum -y install httpd php gcc glibc glibc-common wget perl gd gd-devel unzip zip make openssh-server wget
RUN yum -y install epel-release
RUN yum -y install nrpe nagios-plugins-all

#Configure allowed IP on NRPE
RUN sed -i 's/allowed_hosts=127.0.0.1,::1/allowed_hosts=127.0.0.1,::1,172.17.0.2/' /etc/nagios/nrpe.cfg 

#Home Page
RUN touch /var/www/html/index.html
RUN chmod 755 /var/www/html/index.html
RUN echo 'Client Home' > /var/www/html/index.html

#SSH RUN mkdir /var/run/sshd
RUN echo 'root:rootpasswd' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config 
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd 
RUN echo "export VISIBLE=now" >> /etc/profile
RUN /usr/bin/ssh-keygen -A


#Init script
RUN touch /tmp/inicio_servicios.sh
RUN echo "#!/bin/bash" > /tmp/inicio_servicios.sh
RUN echo "/sbin/nrpe -c /etc/nagios/nrpe.cfg -d" >> /tmp/inicio_servicios.sh
RUN echo "/sbin/httpd -k start" >> /tmp/inicio_servicios.sh
RUN echo "/sbin/sshd -k start" >> /tmp/inicio_servicios.sh
RUN chmod +x /tmp/inicio_servicios.sh
WORKDIR /tmp

#Init script
RUN touch /tmp/ping.sh
RUN echo "ping localhost" >> /tmp/ping.sh
RUN chmod +x /tmp/ping.sh


#Ports to expose (ssh) 
EXPOSE 22 
ENTRYPOINT ["/usr/bin/bash"]
