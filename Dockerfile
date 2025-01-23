# Вибір базового образу
FROM php:8.1-apache

# Встановлення необхідних утиліт та розширень PHP для Magento
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libicu-dev \
    libxslt1-dev \
    libzip-dev \
    default-mysql-client \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    gd \
    intl \
    pdo_mysql \
    xsl \
    soap \
    zip \
    bcmath \
    opcache

# Встановлення Composer (інструмент для керування залежностями)
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Копіюємо файли Magento до контейнера
WORKDIR /var/www/html
COPY . /var/www/html

# Налаштування прав доступу для Magento
RUN chown -R www-data:www-data /var/www/html \
    && a2enmod rewrite

# Налаштування робочого середовища для PHP
RUN echo "memory_limit = 2G" >> /usr/local/etc/php/conf.d/memlimit.ini

# Виконання установки Magento (якщо потрібно)
RUN php bin/magento setup:install \
    --base-url=http://localhost \
    --db-host=db \
    --db-name=magento \
    --db-user=root \
    --db-password=root \
    --backend-frontname=admin \
    --admin-firstname=Admin \
    --admin-lastname=User \
    --admin-email=admin@example.com \
    --admin-user=admin \
    --admin-password=admin123 \
    --language=en_US \
    --currency=USD \
    --timezone=America/Chicago \
    --use-rewrites=1

# Відкриття порту 80 для веб-сервера
EXPOSE 80

# Визначення команди для запуску контейнера
CMD ["apache2-foreground"]
