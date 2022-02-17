FROM php:7.4-fpm

ARG user
ARG uid

RUN apt-get update && apt-get install -y git curl libpng-dev libonig-dev libxml2-dev zip unzip
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer


RUN useradd -G www-data,root -u $uid -d /home/$user $user
COPY . /var/www/
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user && chown -R $user:root /var/www
RUN chmod 755 /var/www/bootstrap/cache

WORKDIR /var/www

USER $user
RUN composer install --no-plugins
RUN composer install 
RUN php artisan key:generate 
EXPOSE 80
CMD php artisan serve --host=0.0.0.0 --port 80
