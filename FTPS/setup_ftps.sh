#!/bin/sh
set -e

# Valores estáticos dentro do container
FTP_PORT=21
PASV_MIN=40000
PASV_MAX=40100

IP_SERVIDOR="${IP_SERVIDOR:-192.168.0.100}"
FTP_USER="${FTP_USER:-alunoftp}"
FTP_PASS="${FTP_PASS:-senha123}"

echo "[1/6] Creating SSL directory..."
mkdir -p /etc/ssl/private
chmod 700 /etc/ssl/private

echo "[2/6] Generating SSL certificate..."
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/vsftpd.pem \
  -out /etc/ssl/certs/vsftpd.pem \
  -subj "/C=BR/ST=SC/L=Videira/O=AngelCorp/OU=IT/CN=ftp.angelcorp.com.br"

echo "[3/6] Writing /etc/vsftpd.conf..."
cat > /etc/vsftpd.conf <<EOF
listen=YES
listen_ipv6=NO
listen_port=${FTP_PORT}

anonymous_enable=NO
local_enable=YES
write_enable=YES
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES

secure_chroot_dir=/var/run/vsftpd/empty

# SSL
ssl_enable=YES
rsa_cert_file=/etc/ssl/certs/vsftpd.pem
rsa_private_key_file=/etc/ssl/private/vsftpd.pem
ssl_tlsv1_2=YES
ssl_tlsv1_3=YES
ssl_sslv2=NO
ssl_sslv3=NO
force_local_data_ssl=YES
force_local_logins_ssl=YES

# Passive Mode
pasv_enable=YES
pasv_min_port=${PASV_MIN}
pasv_max_port=${PASV_MAX}
pasv_address=${IP_SERVIDOR}

chroot_local_user=YES
allow_writeable_chroot=YES
EOF

echo "[4/6] Creating FTP user..."
adduser -D "$FTP_USER"
echo "${FTP_USER}:${FTP_PASS}" | chpasswd
chmod 755 "/home/${FTP_USER}"

echo "[5/6] Ensuring vsftpd runtime dir..."
mkdir -p /var/run/vsftpd/empty

echo "[6/6] FTPS base configuration done. vsftpd will be started by the container command."
echo
echo "=============================================="
echo " FTPS configured on Alpine!"
echo " FTP User: $FTP_USER"
echo " FTP Password: $FTP_PASS"
echo " Server IP: $IP_SERVIDOR"
echo " Control Port (internal): $FTP_PORT"
echo " Passive Ports (internal): ${PASV_MIN}-${PASV_MAX}"
echo "=============================================="
