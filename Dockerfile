FROM ubuntu:latest
MAINTAINER Anthony Kitchin

ENV MYSQL_USER=mysql \
    MYSQL_DATA_DIR=/var/lib/mysql \
    MYSQL_RUN_DIR=/run/mysqld \
    MYSQL_LOG_DIR=/var/log/mysql

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y apache2 php5 libapache2-mod-php5 curl mysql-server-5.6 libcurl3 php5-curl php5-gd php5-mcrypt php5-intl php5-xsl php5-mysql && apt-get -y autoremove && apt-get clean
RUN php5enmod mcrypt 
RUN php5enmod intl
RUN php5enmod xsl
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer
RUN mkdir /usr/local/magento2
ADD auth.json /root/.composer/auth.json
RUN composer create-project magento/community-edition /usr/local/magento2 -s dev --prefer-dist
#RUN find /usr/local/magento2 -type d -exec chmod 700 {} \; && find /usr/local/magento2 -type f -exec chmod 600 {} \;
RUN chown -R www-data /usr/local/magento2
#RUN chgrp -R www-data /usr/local/magento2
ADD magento.conf /etc/apache2/sites-available/magento.conf
RUN a2ensite magento.conf
RUN a2dissite 000-default.conf
RUN a2enmod rewrite
RUN /etc/init.d/mysql start && echo "CREATE DATABASE magento2" | mysql -u root && /etc/init.d/mysql stop

EXPOSE 80

# Default docker process 
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
