#!/bin/bash

set -e

source .env

# Expected environment variables:
# IP_SERVIDOR="x.x.x.x"
# FTP_USER="alunoftp"
# FTP_PASS="senha123"
# FTP_PORT="21001"

if [ -z "$IP_SERVIDOR" ] || [ -z "$FTP_USER" ] || [ -z "$FTP_PASS" ] || [ -z "$FTP_PORT" ]; then
  echo "ERROR: Missing environment variables."
  echo "Required: IP_SERVIDOR, FTP_USER, FTP_PASS, FTP_PORT"
  exit 1
fi

echo "[1/8] Updating packages..."
apt update -y

echo "[2/8] Installing vsftpd..."
apt install vsftpd -y

echo "[3/8] Creating SSL directory..."
mkdir -p /etc/ssl/private
chmod 700 /etc/ssl/private

echo "[4/8] Generating SSL certificate..."
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/vsftpd.pem \
  -out /etc/ssl/certs/vsftpd.pem \
  -subj "/C=BR/ST=SC/L=Videira/O=AngelCorp/OU=IT/CN=ftp.angelcorp.com.br"

echo "[5/8] Writing /etc/vsftpd.conf..."

cat <<EOF > /etc/vsftpd.conf
listen=YES
listen_ipv6=NO

listen_port=${PORTA}

anonymous_enable=NO
local_enable=YES
write_enable=YES

dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES

secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd

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

echo "[6/8] Creating FTP user..."
useradd -m -s /bin/bash "$FTP_USER"
echo "$FTP_USER:$FTP_PASS" | chpasswd
chmod 755 /home/$FTP_USER

echo "[7/8] Restarting vsftpd..."
systemctl restart vsftpd
systemctl enable vsftpd

echo "[8/8] Installing lftp (optional for testing)..."
apt install lftp -y

echo
echo "=============================================="
echo " FTPS successfully configured!"
echo " FTP User:     $FTP_USER"
echo " FTP Password: $FTP_PASS"
echo " Server IP:    $IP_SERVIDOR"
echo " Control Port: $FTP_PORT"
echo
echo " Use FileZilla or lftp to connect using FTPS."
echo "=============================================="
