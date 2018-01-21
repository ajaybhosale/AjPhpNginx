FROM ubuntu:16.04

MAINTAINER Ajay Bhosale<ajay.bhosale@silicus.com>

RUN dpkg-divert --local --rename --add /sbin/initctl && ln -sf /bin/true /sbin/initctl 
ENV DEBIAN_FRONTEND noninteractive
  
RUN apt-get update && \
    apt-get -y upgrade && \    
	apt-get -qq -y --fix-missing install apt-utils \
	software-properties-common \
	python-software-properties \
	nginx \
    php7.0 \
	php7.0-common \
	php7.0-opcache \
	php7.0-mcrypt \
    php7.0-cli \     
    php7.0-gd \
    php7.0-curl \
    php7.0-json \
    php7.0-mbstring \
    php7.0-mysql \
    php7.0-xml \
    php7.0-xsl \
    php7.0-zip \
	php7.0-fpm \
	unixodbc-dev \
	php-pear \     	
	php-mongodb \
	git
	
RUN apt-get update && \
	apt-get -qq -y --fix-missing install \	
	curl
		

COPY default.conf /etc/nginx/sites-available/default

# Update the PHP.ini file, enable <? ?> tags and quieten logging.
RUN sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php/7.0/cli/php.ini && \
	sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php/7.0/cli/php.ini && \
	sed -i "s/cgi.fix_pathinfo = Off/cgi.fix_pathinfo = 0/" /etc/php/7.0/cli/php.ini
	
RUN curl -s https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

RUN git clone -b master https://ajaybhosale:roja786@github.com/ajaybhosale/laravel55.git /var/www/html/workplace 

# Laravel required commands
WORKDIR /var/www/html/workplace

RUN chmod 777 .env && \
	chmod -R 777 storage && \
	composer update && \
	php artisan key:generate && \
	php artisan cache:clear && \
	php artisan config:clear && \
	php artisan view:clear && \
	php artisan optimize

# cleanup apt and lists
RUN apt-get remove --purge -y software-properties-common \
	python-software-properties && \
	apt-get autoremove -y && \
	apt-get clean && \
	apt-get autoclean 	

	
# expose both the HTTP (80) and HTTPS (443) ports
EXPOSE 80 

CMD /etc/init.d/php7.0-fpm start && /etc/init.d/nginx start && /bin/bash