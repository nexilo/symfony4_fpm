FROM php:7.2-fpm
ARG TIMEZONE

MAINTAINER Kamil Bednarek <kamil@nexilo.uk>

RUN apt-get update && apt-get install -y \
    openssl \
    git \
    unzip mc htop vim zlib1g-dev libpng-dev libfreetype6-dev libmcrypt-dev curl libicu-dev g++ wget gnupg apt-transport-https

RUN apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        build-essential \
        libcairo2-dev \
        libjpeg-dev \
        libpango1.0-dev \
        libgif-dev

RUN ln -snf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && echo ${TIMEZONE} > /etc/timezone
RUN printf '[PHP]\ndate.timezone = "%s"\n', ${TIMEZONE} > /usr/local/etc/php/conf.d/tzone.ini
RUN "date"

RUN docker-php-ext-install pdo pdo_mysql zip intl bcmath iconv mbstring exif opcache mbstring gd
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd
RUN docker-php-ext-enable gd

COPY config/memory.ini $PHP_INI_DIR/conf.d/
RUN echo "request_terminate_timeout = 300000" >> /usr/local/etc/php-fpm.d/www.conf
RUN echo "request_terminate_timeout = 300000" >> /usr/local/etc/php-fpm.d/docker.conf

RUN usermod -u 1000 www-data

RUN usermod -u 1000 www-data
RUN groupmod -g 1000 www-data
RUN chsh -s /bin/bash www-data

WORKDIR /var/www/symfony

EXPOSE 9000
