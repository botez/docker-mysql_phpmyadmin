FROM phusion/baseimage:0.9.11
MAINTAINER botez <troyolson1@gmail.com>
ENV DEBIAN_FRONTEND noninteractive

# Set correct environment variables
ENV HOME /root

RUN usermod -u 99 nobody && \
    usermod -g 100 nobody

CMD ["/sbin/my_init"]

RUN apt-get install software-properties-common
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
RUN add-apt-repository 'deb http://ftp.osuosl.org/pub/mariadb/repo/10.0/ubuntu trusty main'
RUN apt-get update -q

# Install sshd
RUN apt-get install -y openssh-server
#RUN mkdir /var/run/sshd

# Set password to 'admin'
RUN printf admin\\nadmin\\n | passwd

# Install MySQL
#RUN apt-get install -y mysql-server mysql-client libmysqlclient-dev
# Install MariaDB
RUN apt-get install -y mariadb-server

# Tweak my.cnf
#RUN sed -i -e 's/\(bind-address.*=\).*/\1 0.0.0.0/g' /etc/mysql/my.cnf
RUN sed -i -e 's/\(log_error.*\)/#\1/g' /etc/mysql/my.cnf
RUN sed -i -e 's/\(user.*=\).*/\1 nobody/g' /etc/mysql/my.cnf

# Install Apache
RUN apt-get install -y apache2
# Install php
RUN apt-get install -y php5 libapache2-mod-php5 php5-mcrypt

# Install phpMyAdmin
RUN mysqld &
RUN service apache2 start
RUN sleep 5
RUN apt-get install -y phpmyadmin
RUN mysqladmin -u root shutdown

RUN sed -i "s#// \$cfg\['Servers'\]\[\$i\]\['AllowNoPassword'\] = TRUE;#\$cfg\['Servers'\]\[\$i\]\['AllowNoPassword'\] = TRUE;#g" /etc/phpmyadmin/config.inc.php 

EXPOSE 22
EXPOSE 80
EXPOSE 3306

VOLUME /db

# Add lamp-phpmyadmin to runit
#RUN mkdir /etc/service/lamp-phpmyadmin
#ADD lamp-phpmyadmin.sh /etc/service/lamp-phpmyadmin/run
#RUN chmod +x /etc/service/lamp-phpmyadmin/run
CMD mysqld_safe --datadir='/db' &
CMD service apache2 start
CMD /usr/sbin/sshd -D

