#!/usr/bin/env bash

if [[ "$EUID" -ne 0 ]]; then
    echo "Este script precisa ser executado como 'sudo'!"
    exit 1
fi

SYS_LOG_DIR="/var/log/nginx/status"
NGINX_SCRIPT="/usr/bin/nginx_status_check.sh"

# Remove o cronjob
(sudo crontab -l | grep "*/5 * * * * $NGINX_SCRIPT") | sudo crontab -

# Remove a pasta de logs
sudo rm -r "$SYS_LOG_DIR"

# Remove o script
sudo rm "$NGINX_SCRIPT"

# Remove o NGINX e dependências
sudo apt purge nginx -y
sudo apt autoremove