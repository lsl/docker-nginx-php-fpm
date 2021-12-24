# [Alpine + Nginx + PHP-FPM8](https://github.com/lsl/docker-nginx-php-fpm)

What could go wrong?

This image aims to simplify building and deploying PHP web applications with a single container you can throw behind [traefik](https://traefik.io/) or [nginx-proxy](https://github.com/jwilder/nginx-proxy).

**⚠️ Please note: This project is no longer maintained, I suggest using this repo as a starting place for your own container.**

## How does it work?

The image runs a Go based [supervisord port](https://github.com/ochinchina/supervisord/) in the foreground which in turn runs nginx/php-fpm in the background. Both nginx & php-fpm are configured to log to stdout/stderr which can then picked up by docker logging as you would expect.

## Why would you do this?

Nginx + PHP-FPM as a single image vs separate images is a bit contentious. While keeping them separate is standard practice: it has a few downsides and not many upsides for most use cases.

This project serves to explore what happens when you treat Nginx + PHP-FPM as a single application and focus on containerization of your code - the thing that really matters.

### Example standalone usage (available at http://localhost/)

`docker run --rm -it -p 80:80 -v ~/www:/www lslio/nginx-php-fpm`

### Example usage with volume map and server name change (available at http://example.localhost/)

`docker run --rm -it -v ~/www:/www -p 80:80 -e SERVER_NAME=example.localhost lslio/nginx-php-fpm`

### Example [Dockerfile](https://github.com/lsl/docker-nginx-php-fpm/blob/master/examples/Dockerfile.basic) usage

```
FROM lslio/nginx-php-fpm

ENV SERVER_NAME=example.com
ENV SERVER_ALIAS=www.example.com
ENV SERVER_ROOT=/www

COPY . /www
```

### Example [docker-compose.yml](https://github.com/lsl/docker-nginx-php-fpm/blob/master/examples/docker-compose.yml)

```
version: '3.6'

services:
  example:
    image: lslio/nginx-php-fpm
    volumes:
      - .:/www
    ports:
      - "80:80"
    environment:
      SERVER_NAME: "example.localhost"
```

### Example [docker-compose.yml](https://github.com/lsl/docker-nginx-php-fpm/blob/master/examples/docker-compose-multisite.yml) for Multiple Laravel installs behind nginx-proxy
```
version: '3.6'

services:
  nginx-proxy:
    image: jwilder/nginx-proxy
    ports:
      - "80:80"
    volumes:
      - /var/run/docker.sock:/tmp/docker.sock:ro

  example-web:
    image: lslio/nginx-php-fpm
    volumes:
      - ./web:/www
    environment:
      VIRTUAL_HOST: "example.localhost"
      SERVER_ROOT: "/www/public"

  example-api:
    image: lslio/nginx-php-fpm
    volumes:
      - ./api:/www
    environment:
      VIRTUAL_HOST: "api.example.localhost"
      SERVER_ROOT: "/www/public"
```

## Props
- Got a lot of ideas from [boxedcode/alpine-nginx-php-fpm](https://gitlab.com/boxedcode/alpine-nginx-php-fpm).
- This golang [supervisord port](https://github.com/ochinchina/supervisord) reduces the final image by about half.
