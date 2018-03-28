# [Alpine + Nginx + PHP-FPM7](https://github.com/lsl/docker-nginx-php-fpm)

What could go wrong?

This image aims to simplify building and deploying PHP web applications with a single container you can throw behind [traefik](https://traefik.io/) or [nginx-proxy](https://github.com/jwilder/nginx-proxy).

This project is a work in progress and a place to test different ways of running nginx + php-fpm in the same container.

*Please note: This image is effectively unstable and likely to have breaking changes for the forseeable future. I suggest using it as a starting point for your own needs.*

## Why

Nginx + PHP-FPM as a single image vs Nginx + PHP-FPM as separate images has always come down to one thing: Where you draw the application boundaries.

This project serves to explore what happens when you treat Nginx / PHP-FPM as implementation details, and your application source code as the thing that needs containerization.

## How

This image runs supervisord in the foreground which in turn runs nginx/php-fpm in the background. Both nginx/php-fpm are configured to log to stdout/stderr which can then picked up by docker logging as you would expect.

### Example standalone usage (available at http://localhost/)

`docker run --rm -it -p80:80 lslio/nginx-php-fpm`

### Example usage with volume map and server name change (available at http://example.localhost/)

`docker run --rm -it -v ~/my/src:/var/www -p 80:80 -e SERVER_NAME=example.localhost lslio/nginx-php-fpm`

### Example Dockerfile usage

```
FROM lslio/nginx-php-fpm

ENV SERVER_NAME=example.com
ENV SERVER_ALIAS="www.example.com api.example.com"
ENV SERVER_PORT=80

# Note: Laravel users will want to use ENV SERVER_ROOT=/var/www/public
ENV SERVER_ROOT=/var/www

COPY . /var/www
```

### Example Dockerfile usage with a [composer](https://github.com/lsl/docker-composer) build step:

```
FROM lslio/composer:latest as composer

COPY ./composer.* /var/www/
RUN composer-install -d /var/www

COPY . /var/www
RUN composer-dump -d /var/www

FROM lslio/nginx-php-fpm

ENV SERVER_NAME=example.com
ENV SERVER_ALIAS="www.example.com api.example.com"
ENV SERVER_PORT=80

# Note: Laravel users will want to use ENV SERVER_ROOT=/var/www/public
ENV SERVER_ROOT=/var/www

# Install extra modules
RUN apk add --no-cache --update -X 'http://dl-cdn.alpinelinux.org/alpine/edge/testing' php7-msgpack php7-gearman

COPY --from=composer --chown=www-data:www-data /var/www /var/www
```

### Example docker-compose.yml
```
version: '3.2'

services:
    example:
        image: lslio/nginx-php-fpm
        volumes:
            - .:/var/www
        ports:
            - "80:80"
        environment:
            SERVER_NAME: "example.localhost"
```

## Props
- Got a lot of ideas from [boxedcode/alpine-nginx-php-fpm](https://gitlab.com/boxedcode/alpine-nginx-php-fpm).
- This golang [supervisord port](https://github.com/ochinchina/supervisord) reduces the final image by about half.
- Projects like [ReactPHP](https://github.com/reactphp/http) and [PHP-PM](https://github.com/php-pm/php-pm) deserve a mention as they point to where PHP docker infrastructure is going and are part of the reason for my opinions leading to this project.
