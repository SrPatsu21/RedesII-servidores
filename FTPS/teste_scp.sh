#!/bin/bash

set -e

source .env

if [ -z "$ARQUIVO" ]; then
    echo "Uso: ./enviar.sh arquivo.txt"
    exit 1
fi

echo "Enviando '$ARQUIVO' para $FTP_USER@$IP_SERVIDOR:$DESTINO ..."
scp -P "$FTP_PORT" "$ARQUIVO" "$FTP_USER@$IP_SERVIDOR:$DESTINO"

if [ $? -eq 0 ]; then
    echo "Arquivo enviado com sucesso!"
else
    echo "Falha ao enviar o arquivo."
fi
