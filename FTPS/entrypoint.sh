#!/bin/bash
set -e

# Variáveis (podem vir do docker env)
FTP_USER=${FTP_USER:-alunoftp}
FTP_PASS=${FTP_PASS:-pass123}
PASV_MIN=${PASV_MIN:-50000}
PASV_MAX=${PASV_MAX:-50003}
PASV_ADDRESS=${PASV_ADDRESS:-10.0.0.5}

# Caminhos dentro do container (use caminhos absolutos que vsftpd espera)
CERT_DIR="/etc/ssl/certs"
KEY_DIR="/etc/ssl/private"
CERT_FILE="${CERT_DIR}/vsftpd.pem"
KEY_FILE="${KEY_DIR}/vsftpd.pem"

# Cria diretórios necessários
mkdir -p "$CERT_DIR" "$KEY_DIR" /home/"$FTP_USER" /var/log

# Gerar certificado (somente se não existir)
if [ ! -f "$CERT_FILE" ] || [ ! -f "$KEY_FILE" ]; then
  echo "Gerando certificado autoassinado em ${CERT_FILE}..."
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "$KEY_FILE" \
    -out "$CERT_FILE" \
    -subj "/C=BR/ST=SC/L=Videira/O=AngelCorp/OU=IT/CN=ftp.angelcorp.com.br"
  chmod 600 "$KEY_FILE"
  echo "Certificado SSL gerado."
else
  echo "Certificado SSL já existe em ${CERT_FILE}."
fi

# Criar usuário FTP/SSH se necessário
if ! id "$FTP_USER" >/dev/null 2>&1; then
  adduser -D -h /home/$FTP_USER -s /bin/bash "$FTP_USER"
fi
echo "${FTP_USER}:${FTP_PASS}" | chpasswd

# Ajustar propriedade da home
chown -R "${FTP_USER}:${FTP_USER}" /home/"$FTP_USER"

# Ajustar vsftpd.conf dinamicamente
if [ -f /etc/vsftpd/vsftpd.conf ]; then
  sed -i "s/^pasv_min_port=.*/pasv_min_port=${PASV_MIN}/" /etc/vsftpd/vsftpd.conf || true
  sed -i "s/^pasv_max_port=.*/pasv_max_port=${PASV_MAX}/" /etc/vsftpd/vsftpd.conf || true
  sed -i "s/^pasv_address=.*/pasv_address=${PASV_ADDRESS}/" /etc/vsftpd/vsftpd.conf || true
  sed -i "s|^local_root=.*|local_root=/home/${FTP_USER}|" /etc/vsftpd/vsftpd.conf || true

  # Garantir que o vsftpd use os caminhos esperados para o certificado
  sed -i "s|^rsa_cert_file=.*|rsa_cert_file=${CERT_FILE}|" /etc/vsftpd/vsftpd.conf || true
  sed -i "s|^rsa_private_key_file=.*|rsa_private_key_file=${KEY_FILE}|" /etc/vsftpd/vsftpd.conf || true
fi

# Gerar chaves host do OpenSSH (se necessário)
ssh-keygen -A >/dev/null 2>&1 || true

# Iniciar SSHD em background
echo "Iniciando sshd..."
/usr/sbin/sshd -D &
SSHD_PID=$!

# Start vsftpd em foreground (substitui o processo atual)
echo "Iniciando vsftpd..."
exec supervisord -n