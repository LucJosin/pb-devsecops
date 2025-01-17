#!/usr/bin/env bash

if [[ "$EUID" -ne 0 ]]; then
    echo "Este script precisa ser executado como 'sudo'!"
    exit 1
fi

validate_input() {
    # Aceita todas as perguntas
    if [[ "$*" == *"-y"* ]]; then
        return 0
    fi

    while true; do
        read -r -p "$1 (y/n): " input
        case "$input" in
            [yY][eE][sS]|[yY])
                return 0
                ;;
            [nN][oO]|[nN])
                return 1
                ;;
            *)
                echo "Opção invalida Use 'y' ou 'n'."
                ;;
        esac
    done
}

if ! validate_input "Iniciando processo de instalação do NGINX, continuar?"; then
    echo "OK :)"
    exit 1
fi

if validate_input "Atualizar pacotes?"; then
    sudo apt update && sudo apt upgrade -y
    echo "Atualização completa!"
fi

SYS_LOG_DIR="/var/log/nginx/status"
NGINX_LOG_ONLINE="$SYS_LOG_DIR/online.log"
NGINX_LOG_OFFLINE="$SYS_LOG_DIR/offline.log"
NGINX_SCRIPT="/usr/bin/nginx_status_check.sh"

sudo apt install nginx -y
echo "NGINX instalado!"

sudo systemctl enable nginx
echo "Atualizado o 'systemctl' para que o NGINX inicie com o sistema"

echo "Para validar, abra o navegador em: 'http://localhost'"

sudo touch /usr/bin/nginx_status_check.sh
echo "Arquivo 'nginx_status_check.sh' criado em '/usr/bin'"

echo `#!/usr/bin/env bash

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
` >> /usr/bin/nginx_status_check.sh
sudo chmod +x $NGINX_SCRIPT

sudo mkdir $SYS_LOG_DIR
sudo chown $USER:$USER $SYS_LOG_DIR

sudo touch $NGINX_LOG_ONLINE $NGINX_LOG_OFFLINE
sudo chmod 744 $NGINX_LOG_ONLINE $NGINX_LOG_OFFLINE
echo "Permissões atualizadas!"

(crontab -l; echo "*/5 * * * * $NGINX_SCRIPT") | crontab -
echo "Cronjob definido para '$NGINX_SCRIPT' rodar a cada 5 minutos!"

echo ""
echo "Use o comando 'tail -f $NGINX_LOG_ONLINE' para ver o status ONLINE e 'tail -f $NGINX_LOG_OFFLINE' para o status OFFLINE"