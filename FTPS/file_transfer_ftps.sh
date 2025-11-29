#!/bin/bash

VM_USER="patsu21"
VM_IP="10.0.0.5"          
VM_SSH_PORT="22"
FTP_PORT="21"
FTP_USER="alunoftp"
FTP_PASS="pass123"
NGINX_DIR="/home/${VM_USER}/nginx_angelcorp/html/www"
LOCAL_FILE="ftps_seguro.html"
FTP_HOME="/home/${FTP_USER}"

# 1. criate file
echo "Este é um arquivo transferido via FTPS seguro para o Nginx!" > $LOCAL_FILE
echo "file created: $LOCAL_FILE"

# 2. transfer file to server
lftp -u $FTP_USER,$FTP_PASS -p $FTP_PORT $VM_IP << EOF
set ftp:ssl-force true
cd $FTP_HOME
put $LOCAL_FILE
bye
EOF

if [ $? -eq 0 ]; then
  echo "transference finished."
else
  echo "Error on FTPS transference."
  exit 1
fi

# Limpar local
rm -f $LOCAL_FILE
