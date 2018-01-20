FROM ubuntu:16.04

MAINTAINER Ajay Bhosale<ajay.bhosale@silicus.com>

# Surpress Upstart errors/warning 
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl

# Let the conatiner know that there is no tty 
ENV DEBIAN_FRONTEND noninteractive
 
RUN apt-get -y update && \
    apt-get -y upgrade && \    
	apt-get -y install && \ 
	nginx && \
    php7.0 && \	  
    php7.0-mbstring && \
	php7.0-mcrypt && \
	php7.0-gd && \
    php7.0-curl && \
    php7.0-json && \
	php7.0-xml && \
    php7.0-xsl && \
    php7.0-zip && \
	php7.0-fpm 	&& \		
	php-pear && \
	php-redis && \	 
	php-mongodb && \
	git && \
	curl


#Set Host	
COPY default.conf /etc/nginx/sites-available/default

# Install Composer	
RUN curl -s https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

RUN git clone -b master https://ajaybhosale:roja786@github.com/ajaybhosale/laravel55.git /var/www/html/workplace 

# Laravel required commands
WORKDIR /var/www/html/workplace

RUN composer update && \
	chmod 777 .env && \
	chmod -R 777 storage  && \
	php artisan key:generate  && \
	php artisan cache:clear && \
	php artisan config:clear && \
	php artisan view:clear && \
	php artisan optimize

# cleanup apt and lists
RUN apt-get clean && apt-get autoclean

# expose the HTTP (80)
EXPOSE 80 9000

#ENTRYPOINT service php7.0-fpm start && service nginx start && /bin/bash
CMD php7.0-fpm -d variables_order="EGPCS" && (tail -F /var/log/nginx/access.log &) && exec nginx -g "daemon off;"