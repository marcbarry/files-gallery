FROM php:8.3.3-apache

RUN apt-get update && apt-get install -y \
        exif \
        ffmpeg \
        libzip-dev \
        libpng-dev \
        libjpeg-dev \
        sudo \
        zip \
        libfreetype6-dev \
        libfontconfig1-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install zip \
    && docker-php-ext-install exif

RUN apt-get clean

ARG UID=1026
ARG GID=101

# By default apache runs as the www-data user (uid: 33) if this doesn't match the dockerhost user that has permissions on the mapped volume
# the container won't be able to access the host file system. Force the uid for the www-data user to match the user id on docker host that 
# can access the mapped volume. (1026 & 101)
RUN usermod --non-unique -u ${UID} www-data
RUN groupmod --non-unique -g ${GID} www-data

# copy files-gallery into container
COPY src/index.php /var/www/html

# customise settings
COPY src/_filesconfig.php /var/www/html/_filesconfig.php

# setup write permissions on /media
RUN mkdir -p /media \
    && mkdir -p /config \
    && chmod -R 755 /media \
    && chmod -R 755 /config \
    && chown -R www-data:www-data /media \ 
    && chown -R www-data:www-data /config