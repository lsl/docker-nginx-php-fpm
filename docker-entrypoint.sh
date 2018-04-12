#!/bin/sh -e

# jwilder/nginx-proxy support
SERVER_NAME=${VIRTUAL_HOST:-${SERVER_NAME:-localhost}}

envsubst '$SERVER_NAME $SERVER_ALIAS $SERVER_ROOT' < /nginx.conf.template > /etc/nginx/nginx.conf

supervisord -c /supervisord.conf

