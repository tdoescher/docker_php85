FROM php:8.5-fpm

RUN apt-get update \
  && apt-get install -y apt-utils mariadb-client libfreetype6-dev libicu-dev libmagickwand-dev libjpeg62-turbo-dev libpng-dev libwebp-dev libzip-dev libavif-dev libaom-dev libdav1d-dev \
  && apt-get clean all

RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp --with-avif \
  && docker-php-ext-configure intl \
  && docker-php-ext-install exif gd intl mysqli pdo pdo_mysql zip

RUN echo 'memory_limit = 1024M' >> $PHP_INI_DIR/conf.d/memorylimit.ini;
RUN echo 'upload_max_filesize = 50M;\npost_max_size = 50M;' >> $PHP_INI_DIR/conf.d/uploadfilesize.ini;
RUN echo  '[www]\npm = dynamic\npm.max_children = 32\npm.process_idle_timeout = 3s' >> /usr/local/etc/php-fpm.d/zz-overrides.conf

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /var/www

USER www-data
