#!/bin/bash
set -e

FTP_USER=${FTP_USER:-alunoftp}
FTP_PASS=${FTP_PASS:-pass123}
PASV_MIN=${PASV_MIN:-50000}
PASV_MAX=${PASV_MAX:-50003}
PASV_ADDRESS=${PASV_ADDRESS:-10.0.0.5}
CERT_DIR="./FTPS/ssl/certs"
KEY_DIR="./FTPS/ssl/private"
CERT_FILE="/etc/ssl/certs/vsftpd.pem"
KEY_FILE="/etc/ssl/private/vsftpd.pem"

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

mkdir -p /home/$FTP_USER /var/log

if ! id "$FTP_USER" >/dev/null 2>&1; then
  adduser -D -h /home/$FTP_USER -s /sbin/nologin "$FTP_USER"
fi
echo "$FTP_USER:$FTP_PASS" | chpasswd

chown -R "$FTP_USER":"$FTP_USER" /home/$FTP_USER

sed -i "s/^pasv_min_port=.*/pasv_min_port=${PASV_MIN}/" /etc/vsftpd/vsftpd.conf
sed -i "s/^pasv_max_port=.*/pasv_max_port=${PASV_MAX}/" /etc/vsftpd/vsftpd.conf
sed -i "s/^pasv_address=.*/pasv_address=${PASV_ADDRESS}/" /etc/vsftpd/vsftpd.conf
sed -i "s|^local_root=.*|local_root=/home/${FTP_USER}|" /etc/vsftpd/vsftpd.conf

exec /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf
