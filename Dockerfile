FROM        ubuntu:saucy
MAINTAINER  Ross Riley "riley.ross@gmail.com"

# Install nginx
RUN echo "deb http://archive.ubuntu.com/ubuntu saucy main universe" > /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y nginx
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# Internal Port Expose
EXPOSE 80 443

# Install PHP5 and modules
RUN apt-get install -y curl git
RUN apt-get -y install php5-fpm php5-mysql php-apc php5-mcrypt php5-curl php5-gd php5-json php5-cli
RUN sed -i -e "s/short_open_tag = Off/short_open_tag = On/g" /etc/php5/fpm/php.ini
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# Configure nginx for PHP websites
RUN echo "cgi.fix_pathinfo = 0;" >> /etc/php5/fpm/php.ini
RUN echo "max_input_vars = 10000;" >> /etc/php5/fpm/php.ini
RUN echo "date.timezone = Europe/London;" >> etc/php5/fpm/php.ini


VOLUME ["/data/pgsql"]
# Install Postgresql
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list ;\
    wget --no-check-certificate --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

RUN apt-get update
RUN apt-get -y install postgresql-9.3
RUN apt-get -y install postgresql-contrib-9.3
RUN chown -R postgres:postgres /data/pgsql


RUN apt-get install -y supervisor
ADD supervisor/nginx.conf /etc/supervisor/conf.d/
ADD supervisor/php.conf /etc/supervisor/conf.d/
ADD supervisor/postgresql.conf /etc/supervisor/conf.d/
ADD supervisor/user.conf /etc/supervisor/conf.d/
ADD supervisor/mysql-runner.sh /etc/supervisor/conf.d/postgresql-start.sh
RUN chmod +x /etc/supervisor/conf.d/postgresql-start.sh

ADD config/nginx.conf /etc/nginx/sites-available/default



CMD ["/usr/bin/supervisord", "-n"]