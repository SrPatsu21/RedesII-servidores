#!/bin/bash
set -e

# Carrega variáveis do .env
if [ -f .env ]; then
  set -a
  . ./.env
  set +a
fi

CERT_DIR="./FTPS/ssl/certs"
KEY_DIR="./FTPS/ssl/private"
CONF_DIR="./FTPS/conf"

CERT_FILE="$CERT_DIR/vsftpd.pem"
KEY_FILE="$KEY_DIR/vsftpd.pem"
CONF_FILE="$CONF_DIR/vsftpd.conf"

mkdir -p "$CERT_DIR" "$KEY_DIR" "$CONF_DIR"

# 1) Certificado
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

# 2) vsftpd.conf usando variáveis PASV_* do ambiente
cat > "$CONF_FILE" << EOF
# Configurações básicas
anonymous_enable=NO
local_enable=YES
write_enable=YES
chroot_local_user=YES
allow_writeable_chroot=YES

# Configurações SSL
ssl_enable=YES
rsa_cert_file=/etc/ssl/certs/vsftpd.pem
rsa_private_key_file=/etc/ssl/private/vsftpd.pem
ssl_tlsv1_2=YES
ssl_tlsv1_3=YES
ssl_sslv2=NO
ssl_sslv3=NO
force_local_data_ssl=YES
force_local_logins_ssl=YES

# PASV (use variáveis externas do .env)
pasv_enable=YES
pasv_min_port=${PASV_MIN}
pasv_max_port=${PASV_MAX}
pasv_address=0.0.0.0

# Outras diretivas úteis
listen=YES
listen_ipv6=NO
pasv_addr_resolve=NO
EOF

echo "vsftpd.conf gerado em: $CONF_FILE"
