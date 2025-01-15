#!/usr/bin/env bash

# Localização dos arquivos de log do sistema
SYS_LOG_DIR="/var/log/nginx"

# Localização dos nossos arquivos de log online e offline
NGINX_LOG_ONLINE="$SYS_LOG_DIR/status_online.log"
NGINX_LOG_OFFLINE="$SYS_LOG_DIR/status_offline.log"

# Data atual
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# Verifica o status atual e escreve nos arquivos 'NGINX_LOG_ONLINE' ou 'NGINX_LOG_OFFLINE'
if systemctl is-active --quiet nginx; then
        echo "$DATE NGINX: O serviço está ONLINE" >> "$NGINX_LOG_ONLINE"
else
        echo "$DATE NGINX: O serviço está OFFLINE" >> "$NGINX_LOG_OFFLINE"
fi
