#!/bin/bash

VM_IP="10.0.0.5"
FTP_PORT="21"
FTP_USER="alunoftp"
FTP_PASS="pass123"
LOCAL_FILE="ftps_seguro.html"

# 1. Criar arquivo local
echo "Este é um arquivo transferido via FTPS seguro para o Nginx!" > "$LOCAL_FILE"
echo "file created: $LOCAL_FILE"

# 2. Transferir arquivo via FTPS
lftp -u "$FTP_USER","$FTP_PASS" -p "$FTP_PORT" "$VM_IP" << EOF
set ftp:passive-mode true
set ftp:prefer-epsv false
set ftp:ssl-force true
set ftp:ssl-protect-data true
set ssl:verify-certificate false
put $LOCAL_FILE
bye
EOF

if [ $? -eq 0 ]; then
  echo "transference finished."
else
  echo "Error on FTPS transference."
  rm -f "$LOCAL_FILE"
  exit 1
fi

# 3. Remover arquivo local
rm -f "$LOCAL_FILE"
