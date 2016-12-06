FROM ubuntu:latest
MAINTAINER Anthony Kitchin

ENV MYSQL_USER=mysql \
    MYSQL_DATA_DIR=/var/lib/mysql \
    MYSQL_RUN_DIR=/run/mysqld \
    MYSQL_LOG_DIR=/var/log/mysql

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y git apache2 php libapache2-mod-php curl mysql-server-5.7 libcurl3 php-curl php-gd php-mcrypt php-intl php-xsl php-mysql php-mbstring php-zip supervisor && apt-get -y autoremove && apt-get clean
RUN phpenmod mcrypt 
RUN phpenmod intl
RUN phpenmod xsl
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

# configure supervisor
ADD supervisor/conf.d/* /etc/supervisor/conf.d/

EXPOSE 80

# Default docker process
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf", "-n"]
