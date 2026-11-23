FROM php:8.5-fpm

RUN apt-get update \
  && apt-get install -y --no-install-recommends mariadb-client libfreetype6-dev libicu-dev libjpeg62-turbo-dev libpng-dev libwebp-dev libzip-dev libavif-dev \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp --with-avif \
  && docker-php-ext-install -j$(nproc) exif gd intl mysqli pdo pdo_mysql zip

COPY --from=mlocati/php-extension-installer:latest /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions imagick

RUN cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
  && { \
    echo 'memory_limit = 1024M'; \
    echo 'upload_max_filesize = 50M'; \
    echo 'post_max_size = 50M'; \
    echo 'date.timezone = Europe/Berlin'; \
  } > $PHP_INI_DIR/conf.d/zz-app.ini

RUN { \
    echo '[www]'; \
    echo 'pm = ondemand'; \
    echo 'pm.max_children = 32'; \
    echo 'pm.process_idle_timeout = 3s'; \
  } > /usr/local/etc/php-fpm.d/zz-overrides.conf

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

WORKDIR /var/www

USER www-data
