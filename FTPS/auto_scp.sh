#!/bin/bash

# Configurações (ajuste estes valores)
VM_USER="seu_usuario_vm"
VM_IP="10.0.0.5"
VM_SSH_PORT="22001"  # Porta SSH mapeada
NGINX_DIR="/home/${VM_USER}/nginx_angelcorp/html/www"
LOCAL_DIR="."

# 4.3.2: Transferir da local para VM
LOCAL_FILE="scp_seguro.txt"
echo "Este é um arquivo transferido via SCP seguro!" > $LOCAL_FILE
scp -P $VM_SSH_PORT $LOCAL_FILE $VM_USER@$VM_IP:$NGINX_DIR/
if [ $? -eq 0 ]; then
  echo "Transferência para VM concluída."
  echo "Verifique no navegador: http://www.angelcorp.com.br:<PORTA_HTTP>/$LOCAL_FILE"
else
  echo "Erro na transferência para VM."
fi

# 4.3.3: Transferir da VM para local
VM_FILE="arquivo_do_servidor.txt"
# Criar na VM se não existir
ssh -p $VM_SSH_PORT $VM_USER@$VM_IP "echo 'Conteúdo do servidor para a máquina local.' > $NGINX_DIR/$VM_FILE"
scp -P $VM_SSH_PORT $VM_USER@$VM_IP:$NGINX_DIR/$VM_FILE $LOCAL_DIR/
if [ $? -eq 0 ]; then
  echo "Transferência da VM para local concluída: $VM_FILE"
  # Limpar na VM
  ssh -p $VM_SSH_PORT $VM_USER@$VM_IP "rm $NGINX_DIR/$VM_FILE"
else
  echo "Erro na transferência da VM."
fi

# Limpar local
rm -f $LOCAL_FILE $VM_FILE
