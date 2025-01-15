#!/usr/bin/env bash

# Localização dos arquivos de log do sistema
SYS_LOG_DIR="/var/log/nginx"

# Localização dos nossos arquivos de log online e offline
NGINX_LOG_ONLINE="$SYS_LOG_DIR/log_online.log"
NGINX_LOG_OFFLINE="$SYS_LOG_DIR/log_offline.log"

# Cria os arquivos de log e adiciona permissão de leitura e escrita
# Necessário por conta da localização (/var/log/)
touch "$NGINX_LOG_ONLINE"
touch "$NGINX_LOG_OFFLINE"
chmod 644 "$NGINX_LOG_ONLINE"
chmod 644 "$NGINX_LOG_OFFLINE"

# Data atual
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# Verifica o status atual e escreve nos arquivos 'NGINX_LOG_ONLINE' ou 'NGINX_LOG_OFFLINE'
if systemctl is-active --quiet nginx; then
        echo "$DATE NGINX: O serviço está ONLINE" >> "$NGINX_LOG_ONLINE"
else
        echo "$DATE NGINX: O serviço está OFFLINE" >> "$NGINX_LOG_OFFLINE"
fi
