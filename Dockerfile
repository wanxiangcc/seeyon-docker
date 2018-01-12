FROM ubuntu:16.04
MAINTAINER wx <wanxiangcc@gmail.com>

# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl
 
# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get -y upgrade	

# vi editor
RUN apt-get -y install vim

# Basic Requirements
RUN apt-get -y install php-dev php-fpm php-mysql 
RUN apt-get -y install curl unzip
RUN apt-get -y install nginx 

# data Requirements
RUN apt-get -y install php-pear
RUN apt-get -y install php-curl php-gd php-intl php-imagick php-imap php-mcrypt php-memcache php-pspell php-recode php-tidy php-xmlrpc php-xsl php-json
RUN apt-get -y install openssl 
RUN pecl install swoole 
RUN pecl install seaslog
RUN pecl install ps
RUN pecl install sqlite
RUN pecl install pdo

# nginx config
RUN sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf
RUN sed -i -e"s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 100m/" /etc/nginx/nginx.conf
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
 
# php-fpm config
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php/7.0/fpm/php.ini
RUN sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 1024M/g" /etc/php/7.0/fpm/php.ini
RUN sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" /etc/php/7.0/fpm/php.ini
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.0/fpm/php-fpm.conf
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
