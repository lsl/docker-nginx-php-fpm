FROM alpine:3.7

# Setup user & /var/www dir
RUN adduser -D -u 1000 -g 1000 -s /bin/sh -h /var/www www-data

# PHP/FPM + Modules
RUN apk add --no-cache --update \
    php7 \
    php7-apcu \
    php7-bcmath \
    php7-bz2 \
    php7-ctype \
    php7-curl \
    php7-dom \
    php7-fpm \
    php7-ftp \
    php7-gd \
    php7-iconv \
    php7-json \
    php7-mbstring \
    php7-oauth \
    php7-opcache \
    php7-openssl \
    php7-pcntl \
    php7-pdo \
    php7-pdo_mysql \
    php7-phar \
    php7-redis \
    php7-session \
    php7-simplexml \
    php7-tokenizer \
    php7-xdebug \
    php7-xml \
    php7-xmlwriter \
    php7-zip \
    php7-zlib \
    php7-zmq

# tini - 'cause zombies - see: https://github.com/ochinchina/supervisord/issues/60
# gettext - nginx envsubst
RUN apk add --no-cache --update \
    tini \
    gettext \
    nginx && \
    rm -rf /var/www/localhost

# Fix nginx dirs/perms
RUN mkdir -p /var/cache/nginx && \
    chown -R www-data:www-data /var/cache/nginx && \
    chown -R www-data:www-data /var/lib/nginx && \
    chown -R www-data:www-data /var/tmp/nginx

# Install a golang port of supervisord
COPY --from=ochinchina/supervisord:latest /usr/local/bin/supervisord /usr/bin/supervisord

# Runtime env vars are envstub'd into config during entrypoint
ENV SERVER_NAME="localhost"
ENV SERVER_ALIAS=""
ENV SERVER_ROOT=/var/www
# Alias defaults to empty, example usage:
# SERVER_ALIAS='www.example.com'

COPY manifest /

WORKDIR /var/www

# nginx: 80, xdebug: 9000 (currently disabled)
EXPOSE 80 9000

ENTRYPOINT ["tini", "--"]
CMD ["supervisord", "-c", "/etc/supervisord.conf"]
