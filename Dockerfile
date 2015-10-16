FROM debian:jessie

MAINTAINER Sergey Marin <marin.sergey@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

# Adding the official Oracle MySQL APT repositories to install MySQL 5.6 (including the apt-get key)
RUN echo "deb http://repo.mysql.com/apt/debian/ jessie mysql-apt-config" >> /etc/apt/sources.list && \
	echo "deb http://repo.mysql.com/apt/debian/ jessie mysql-5.6" >> /etc/apt/sources.list && \
	echo "deb-src http://repo.mysql.com/apt/debian/ jessie mysql-5.6" >> /etc/apt/sources.list && \
	apt-key adv --keyserver keys.gnupg.net --recv-keys 5072E1F5

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates \
      mysql-server \
      redis-server \
      git \
      curl \
      nginx \
      php5 \
      php5-redis \
      php5-curl \
      php5-fpm \
      php5-intl \
      php5-mysql \
      php5-memcache \
      php-twig \
      supervisor \
    && rm -rf /var/lib/apt/lists/*

# Installing composer
RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer && chmod +x /usr/local/bin/composer

# Configure PHP-FPM & Nginx
RUN sed -e 's/;daemonize = yes/daemonize = no/' -i /etc/php5/fpm/php-fpm.conf \
    && sed -e 's/;listen\.owner/listen.owner/' -i /etc/php5/fpm/pool.d/www.conf \
    && sed -e 's/;listen\.group/listen.group/' -i /etc/php5/fpm/pool.d/www.conf \
    && echo "opcache.enable=1" >> /etc/php5/mods-available/opcache.ini \
    && echo "opcache.enable_cli=1" >> /etc/php5/mods-available/opcache.ini \
    && echo "\ndaemon off;" >> /etc/nginx/nginx.conf

ADD supervisor.conf /etc/supervisor/conf.d/supervisor.conf
ADD vhost.conf /etc/nginx/sites-available/default

RUN usermod -u 1000 www-data

VOLUME /var/www
WORKDIR /var/www

EXPOSE 80

CMD ["/usr/bin/supervisord"]
