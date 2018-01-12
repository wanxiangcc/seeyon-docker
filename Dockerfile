FROM ubuntu:16.04
MAINTAINER wx <wanxiangcc@gmail.com>

# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl
 
# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get -y upgrade

# vi editor
RUN apt-get -y install vim

# Basic Requirements
RUN apt-get -y install php-dev php-fpm php-mysql 
RUN apt-get -y install curl unzip
RUN apt-get -y install nginx 

# data Requirements
# php-pear is pecl commond
RUN apt-get -y install php-pear openssl
RUN apt-get -y install php-curl php-gd php-intl php-imagick php-imap php-mcrypt php-memcache php-pspell php-recode php-tidy php-xmlrpc php-xsl php-json

RUN pecl install swoole 
RUN echo "extension=swoole.so" >> /etc/php/7.0/fpm/conf.d/swoole.ini \
	>> /etc/php/7.0/cli/conf.d/swoole.ini
	
RUN pecl install seaslog
RUN echo "extension=seaslog.so\n" \
	"[seaslog]\n" \
	"seaslog.default_basepath = /var/logs/seaslog\n" \
	"seaslog.default_logger = default\n" \
	"seaslog.disting_type = 1\n" \
	"seaslog.disting_by_hour = 0 \n" \
	"seaslog.disting_by_day = 1\n" \
	"seaslog.use_buffer = 1\n" \
	"seaslog.buffer_size = 100\n" \
	"seaslog.level = 0" \
	>> /etc/php/7.0/fpm/conf.d/seaslog.ini \
	>> /etc/php/7.0/cli/conf.d/seaslog.ini
	
# nginx config
RUN sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf
RUN sed -i -e"s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 100m/" /etc/nginx/nginx.conf
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
 
# php-fpm config
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php/7.0/fpm/php.ini
RUN sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 1024M/g" /etc/php/7.0/fpm/php.ini
RUN sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" /etc/php/7.0/fpm/php.ini
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.0/fpm/php-fpm.conf
RUN mkdir /run/php && chmod -R 777 /run/php
RUN sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php/7.0/fpm/pool.d/www.conf
RUN find /etc/php/7.0/cli/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;
 
# nginx site conf ,copy this server file to docker
# ADD ./nginx-site.conf /etc/nginx/sites-available/default
 
# Supervisor Config
RUN apt-get -y install supervisor
# RUN apt-get -y install supervisor-stdout
# Supervisor Config,copy this server file to docker
#ADD ./supervisord.conf /etc/supervisord.conf
 

# private expose
EXPOSE 80
EXPOSE 443
