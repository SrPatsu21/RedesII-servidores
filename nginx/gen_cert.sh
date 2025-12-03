#!/bin/sh

SSL_DIR="./nginx/ssl"

mkdir -p "$SSL_DIR"

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "$SSL_DIR/nginx-selfsigned.key" \
    -out "$SSL_DIR/nginx-selfsigned.crt" \
    -subj "/C=BR/ST=SC/L=Videira/O=AngelCorp/OU=IT/CN=www.angelcorp.com.br"
