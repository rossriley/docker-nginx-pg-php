FROM        ubuntu:14.04
MAINTAINER  Ross Riley "riley.ross@gmail.com"

# Install nginx
RUN apt-get update
RUN apt-get install -y nginx
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# Internal Port Expose
EXPOSE 80 443

RUN locale-gen en_US.UTF-8 && \
    echo 'LANG="en_US.UTF-8"' > /etc/default/locale
RUN dpkg-reconfigure locales


VOLUME ["/data/pgsql"]
# Install Postgresql
RUN apt-get update
RUN apt-get -y install postgresql-9.3
RUN apt-get -y install postgresql-contrib-9.3

# We start it here to allow the default directory to seed with the db setup
RUN /etc/init.d/postgresql start
RUN sed -i -e"s/data_directory =.*$/data_directory = '\/data\/pgsql'/" /etc/postgresql/9.3/main/postgresql.conf
RUN echo 'host all all 0.0.0.0/0 md5' >> /etc/postgresql/9.3/main/pg_hba.conf
RUN echo 'adminmap   postgres         postgres' >> /etc/postgresql/9.3/main/pg_ident.conf
RUN echo 'adminmap   root             postgres' >> /etc/postgresql/9.3/main/pg_ident.conf
RUN chown -R postgres:postgres /data/

# Install PHP5 and modules
RUN apt-get install -y curl git
RUN apt-get -y install php5-fpm php5-pgsql php-apc php5-mcrypt php5-curl php5-gd php5-json php5-cli
RUN sed -i -e "s/short_open_tag = Off/short_open_tag = On/g" /etc/php5/fpm/php.ini
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# Configure nginx for PHP websites
RUN echo "cgi.fix_pathinfo = 0;" >> /etc/php5/fpm/php.ini
RUN echo "max_input_vars = 10000;" >> /etc/php5/fpm/php.ini
RUN echo "date.timezone = Europe/London;" >> etc/php5/fpm/php.ini


RUN apt-get install -y supervisor
ADD supervisor/nginx.conf /etc/supervisor/conf.d/
ADD supervisor/php.conf /etc/supervisor/conf.d/
ADD supervisor/postgresql.conf /etc/supervisor/conf.d/
ADD supervisor/user.conf /etc/supervisor/conf.d/
ADD supervisor/postgresql-start.sh /etc/supervisor/conf.d/postgresql-start.sh
RUN chmod +x /etc/supervisor/conf.d/postgresql-start.sh

ADD config/nginx.conf /etc/nginx/sites-available/default



CMD ["/usr/bin/supervisord", "-n"]