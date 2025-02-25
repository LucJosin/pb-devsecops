#!/usr/bin/env bash

if [[ "$EUID" -ne 0 ]]; then
    echo "Este script precisa ser executado como 'sudo'!"
    exit 1
fi

validate_input() {
    # Aceita todas as perguntas
    if [[ "$*" == *"-s"* || "$*" == *"-y"* ]]; then
        return 0
    fi

    while true; do
        read -r -p "$1 (s/n): " input
        case "$input" in
            [sS]|[yY])
                return 0
                ;;
            [nN])
                return 1
                ;;
            *)
                echo "Opção invalida. Use 's' ou 'n'"
                ;;
        esac
    done
}

# Atualizar os pacotes, opcional
if validate_input "Atualizar pacotes?" $@; then
    sudo apt update && sudo apt upgrade -y
    clear -x
    echo "Atualização completa!"
fi

# Confirmação
if ! validate_input "Iniciando processo de instalação do NGINX, continuar?" $@; then
    echo "OK :)"
    exit 1
fi

SYS_LOG_DIR="/var/log/nginx/status"
NGINX_LOG_ONLINE="$SYS_LOG_DIR/online.log"
NGINX_LOG_OFFLINE="$SYS_LOG_DIR/offline.log"
NGINX_SCRIPT="/usr/bin/nginx_status_check.sh"

# Instala o NGINX
sudo apt install nginx -y
clear -x
echo "NGINX instalado!"

# Ativa o NGINX
sudo systemctl enable nginx
echo "Atualizado o 'systemctl' para que o NGINX inicie com o sistema"

# Criar o arquivo de script
sudo touch /usr/bin/nginx_status_check.sh
echo "Arquivo 'nginx_status_check.sh' criado em '/usr/bin'"

# Escreve o script no arquivo
echo """#!/usr/bin/env bash

# Utilize o script em 'https://lucjos.in/g/clean' para reverter todas as mudanças.

# Localização dos arquivos de log do sistema
SYS_LOG_DIR="/var/log/nginx/status"

# Localização dos nossos arquivos de log online e offline
NGINX_LOG_ONLINE="\$SYS_LOG_DIR/online.log"
NGINX_LOG_OFFLINE="\$SYS_LOG_DIR/offline.log"

# Data atual
DATE=\$(date '+%Y-%m-%d %H:%M:%S')

# Verifica o status atual e escreve nos arquivos 'NGINX_LOG_ONLINE' ou 'NGINX_LOG_OFFLINE'
if systemctl is-active --quiet nginx; then
    echo "$\DATE status: O serviço NGINX está ONLINE" >> "$\NGINX_LOG_ONLINE"
else
    echo "$\DATE status: O serviço NGINX está OFFLINE" >> "$\NGINX_LOG_OFFLINE"
fi
""" > $NGINX_SCRIPT
# Atualiza a permissão de execução
sudo chmod +x $NGINX_SCRIPT

# Prepara a pasta de log
sudo mkdir $SYS_LOG_DIR

# Prepara os arquivos de log e adiciona as permissões necessárias
sudo touch $NGINX_LOG_ONLINE $NGINX_LOG_OFFLINE
sudo chmod 644 $NGINX_LOG_ONLINE $NGINX_LOG_OFFLINE
echo "Permissões atualizadas!"

# Define o cronjob a cada 5 minutos
(sudo crontab -l 2>/dev/null; echo "*/5 * * * * $NGINX_SCRIPT") | sudo crontab - #STDOUT
echo "Cronjob definido para o script '$NGINX_SCRIPT' rodar a cada 5 minutos!"

# Finaliza
echo ""
echo "Script finalizado! Monitoramento do NGINX está ATIVO"
echo "Para validar, abra o navegador em: 'http://localhost'"
echo ""
echo "O script de monitorameto está localizado em: $NGINX_SCRIPT"
echo "Os arquvos de log estão na pasta: $SYS_LOG_DIR"
echo ""
echo "Use o comando 'tail -f $NGINX_LOG_ONLINE' para ver o status ONLINE e 'tail -f $NGINX_LOG_OFFLINE' para o status OFFLINE"
echo ""
echo "ATENÇÃO: O script usa o contexto do 'root/sudo', então os arquivos de log, o script e o cronjob estão todos 'no nome do root'."
echo ""