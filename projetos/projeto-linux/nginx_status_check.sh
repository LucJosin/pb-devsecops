#!/usr/bin/env bash

# Utilize o script em 'https://lucjos.in/g/clean' para reverter todas as mudanças.

# Localização dos arquivos de log do sistema
SYS_LOG_DIR="/var/log/nginx/status"

# Localização dos nossos arquivos de log online e offline
NGINX_LOG_ONLINE="$SYS_LOG_DIR/online.log"
NGINX_LOG_OFFLINE="$SYS_LOG_DIR/offline.log"

# Data atual
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# Verifica o status atual e escreve nos arquivos 'NGINX_LOG_ONLINE' ou 'NGINX_LOG_OFFLINE'
if systemctl is-active --quiet nginx; then
        echo "$DATE status: O serviço NGINX está ONLINE" >> "$NGINX_LOG_ONLINE"
else
        echo "$DATE status: O serviço NGINX está OFFLINE" >> "$NGINX_LOG_OFFLINE"
fi