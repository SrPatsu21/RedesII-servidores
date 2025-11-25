#!/bin/bash

set -e

source .env

# requires: IP_SERVIDOR, FTP_USER, FTP_PASS, FTP_PORT

if [ -z "$IP_SERVIDOR" ] || [ -z "$FTP_USER" ] || [ -z "$FTP_PASS" ] || [ -z "$FTP_PORT" ]; then
  echo "ERROR: Missing environment variables."
  exit 1
fi

echo "[1/4] Installing lftp..."
apt install -y lftp

echo "[2/4] Testing FTPS secure connection..."
lftp -u "$FTP_USER","$FTP_PASS" -p "$FTP_PORT" "$IP_SERVIDOR" <<EOF
set ftp:ssl-force true
set ftp:ssl-protect-data true
ls
bye
EOF

echo "[3/4] Creating test file..."
echo "Este é um arquivo transferido via FTPS seguro para o Nginx!" > ftps_seguro.html

echo "[4/4] Uploading file..."
lftp -u "$FTP_USER","$FTP_PASS" -p "$FTP_PORT" "$IP_SERVIDOR" <<EOF
set ftp:ssl-force true
set ftp:ssl-protect-data true
cd /home/$FTP_USER
put ftps_seguro.html
bye
EOF

echo
echo "Upload completed!"
echo "Now move the file inside the VM using SSH:"
echo "sudo mv /home/$FTP_USER/ftps_seguro.html /home/<YOUR_VM_USER>/nginx_angelcorp/html/www/"
echo
echo "Then access: http://www.angelcorp.com.br:<YOUR_HTTP_PORT>/ftps_seguro.html"
