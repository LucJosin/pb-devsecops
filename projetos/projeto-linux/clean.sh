#!/usr/bin/env bash

if [[ "$EUID" -ne 0 ]]; then
    echo "Este script precisa ser executado como 'sudo'!"
    exit 1
fi

SYS_LOG_DIR="/var/log/nginx/status"
NGINX_SCRIPT="/usr/bin/nginx_status_check.sh"

# Remove o NGINX e dependências
sudo apt purge nginx -y
sudo apt autoremove -y
clear -x

# Remove o cronjob
(sudo crontab -l | grep "*/5 * * * * $NGINX_SCRIPT") | sudo crontab -
echo "Cronjob removido!"

# Remove a pasta de logs
sudo rm -r "$SYS_LOG_DIR"
echo "Pasta '$SYS_LOG_DIR' removida!"

# Remove o script
sudo rm "$NGINX_SCRIPT"
echo "Script '$NGINX_SCRIPT' apagado!"

# Finaliza
echo ""
echo "Script finalizado! Monitoramento do NGINX foi REMOVIDO"
echo ""