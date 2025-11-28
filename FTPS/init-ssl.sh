#!/bin/bash
set -e

# Gerar certificado SSL autoassinado se não existir
CERT_DIR="/etc/ssl/certs"
KEY_DIR="/etc/ssl/private"
CERT_FILE="$CERT_DIR/vsftpd.pem"
KEY_FILE="$KEY_DIR/vsftpd.pem"

if [ ! -f "$CERT_FILE" ] || [ ! -f "$KEY_FILE" ]; then
  mkdir -p "$CERT_DIR" "$KEY_DIR"
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "$KEY_FILE" \
    -out "$CERT_FILE" \
    -subj "/C=BR/ST=SC/L=Videira/O=AngelCorp/OU=IT/CN=ftp.angelcorp.com.br"
  chmod 600 "$KEY_FILE"
  echo "Certificado SSL gerado com sucesso."
fi

# Configurar vsftpd.conf com SSL e PASV (sobrescreve o default)
cat > /etc/vsftpd/vsftpd.conf << EOF
# Configurações existentes (mantidas via env)
anonymous_enable=NO
local_enable=YES
write_enable=YES
chroot_local_user=YES
allow_writeable_chroot=YES
$(env | grep ^PASV_ | sed 's/PASV_\(.*\)=\(.*\)/\L\1\E=\2/g' | tr '\n' '\n')

# Configurações SSL
ssl_enable=YES
rsa_cert_file=$CERT_FILE
rsa_private_key_file=$KEY_FILE
ssl_tlsv1_2=YES
ssl_tlsv1_3=YES
ssl_sslv2=NO
ssl_sslv3=NO
force_local_data_ssl=YES
force_local_logins_ssl=YES

# PASV (use variável externa do .env para IP do servidor)
pasv_enable=YES
pasv_min_port=$(echo $PASV_MIN_PORT | grep -o '[0-9]*' || echo 40000)
pasv_max_port=$(echo $PASV_MAX_PORT | grep -o '[0-9]*' || echo 40005)
pasv_address=$PASV_ADDRESS_EXTERNAL
EOF

# Permissões
chown -R vsftpd:vsftpd /etc/ssl /home/vsftpd /var/log/vsftpd

# Prosseguir com entrypoint original
exec /usr/bin/vsftpd /etc/vsftpd/vsftpd.conf
