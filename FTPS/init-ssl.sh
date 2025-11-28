#!/bin/bash
set -e

CERT_DIR="./FTPS/ssl/certs"
KEY_DIR="./FTPS/ssl/private"
CERT_FILE="$CERT_DIR/vsftpd.pem"
KEY_FILE="$KEY_DIR/vsftpd.pem"

mkdir -p "$CERT_DIR" "$KEY_DIR"

if [ ! -f "$CERT_FILE" ] || [ ! -f "$KEY_FILE" ]; then
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "$KEY_FILE" \
    -out "$CERT_FILE" \
    -subj "/C=BR/ST=SC/L=Videira/O=AngelCorp/OU=IT/CN=ftp.angelcorp.com.br"
  chmod 600 "$KEY_FILE"
  echo "Certificado SSL gerado."
else
  echo "Certificado já existe."
fi
