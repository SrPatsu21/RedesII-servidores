#!/bin/bash

# Configurações (ajuste estes valores)
VM_USER="seu_usuario_vm"  # Usuário da VM
VM_IP="10.0.0.5"          # IP da VM/servidor
VM_SSH_PORT="22"          # Porta SSH mapeada (se não for 22)
FTP_PORT="21"             # Porta FTP mapeada
FTP_USER="alunoftp"
FTP_PASS="pass123"
NGINX_DIR="/home/${VM_USER}/nginx_angelcorp/html/www"
LOCAL_FILE="ftps_seguro.html"
FTP_HOME="/home/${FTP_USER}"

# 1. Criar arquivo local
echo "Este é um arquivo transferido via FTPS seguro para o Nginx!" > $LOCAL_FILE
echo "Arquivo criado: $LOCAL_FILE"

# 2. Transferir via LFTP para diretório FTP
lftp -p $FTP_PORT -u $FTP_USER,$FTP_PASS $VM_IP << EOF
set ftp:ssl-force true
cd $FTP_HOME
put $LOCAL_FILE
bye
EOF

if [ $? -eq 0 ]; then
  echo "Transferência FTPS concluída."
else
  echo "Erro na transferência FTPS."
  exit 1
fi

# 3. Mover na VM via SSH
ssh -p $VM_SSH_PORT $VM_USER@$VM_IP "sudo mv $FTP_HOME/$LOCAL_FILE $NGINX_DIR/"
if [ $? -eq 0 ]; then
  echo "Arquivo movido para Nginx na VM."
  echo "Verifique no navegador: http://www.angelcorp.com.br:<PORTA_HTTP>/$LOCAL_FILE"
else
  echo "Erro ao mover arquivo na VM."
fi

# Limpar local
rm -f $LOCAL_FILE
