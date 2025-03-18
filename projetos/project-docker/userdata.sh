#!/usr/bin/env bash

# Atualiza os pacotes e instala pacotes:
echo "[userdata.sh] Updating packages..."
sudo apt update && sudo apt upgrade -y && sudo apt install -y jq unzip
echo "[userdata.sh] Updated packages!"

# Instala o AWS CLI:

echo "[userdata.sh] Installing AWS CLI..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscli-exe-linux-x86_64.zip"
unzip -q awscli-exe-linux-x86_64.zip
sudo ./aws/install
rm -rf aws awscli-exe-linux-x86_64.zip
AWS_CLI_INFO=$(aws --version)
echo "[userdata.sh] Done! Installed AWS CLI version $AWS_CLI_INFO"

# Configura os segredos do AWS Secret Manager:

## Pega os segredos:
echo "[userdata.sh] Setting up secrets..."
SECRETS=$(aws secretsmanager get-secret-value --secret-id wordpress/docker/credentials --query SecretString --output text | jq -r '.WPDockerSecrets')

## Extrai e seta os valores individuais:
WORDPRESS_DB_HOST=$(echo "$SECRETS" | jq -r '.WORDPRESS_DB_HOST')
WORDPRESS_DB_USER=$(echo "$SECRETS" | jq -r '.WORDPRESS_DB_USER')
WORDPRESS_DB_PASSWORD=$(echo "$SECRETS" | jq -r '.WORDPRESS_DB_PASSWORD')
WORDPRESS_DB_NAME=$(echo "$SECRETS" | jq -r '.WORDPRESS_DB_NAME')
EFS_ENDPOINT=$(echo "$SECRETS" | jq -r '.EFS_ENDPOINT')
echo "[userdata.sh] Done! All secrets configured."

# Amazon CloudWatch Agent

## Instala o pacote do CloudWatch Agent
echo "[userdata.sh] Setting up CloudWatch Agent..."
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i amazon-cloudwatch-agent.deb

# Cria o arquivo de configuração
CW_AGENT_CONFIG_PATH="/opt/aws/amazon-cloudwatch-agent/etc"
sudo mkdir -p "$CW_AGENT_CONFIG_PATH"
cat << EOF > "$CW_AGENT_CONFIG_PATH/cloudwatch-agent.json"
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "root",
    "logfile": "$CW_AGENT_CONFIG_PATH/cloudwatch-agent.json"
  },
  "metrics": {
    "append_dimensions": {
      "InstanceId": "\${aws:InstanceId}"
    },
    "aggregation_dimensions": [["InstanceId"]],
    "metrics_collected": {
      "cpu": {
        "measurement": ["cpu_usage_idle", "cpu_usage_iowait", "cpu_usage_user", "cpu_usage_system", "cpu_usage_steal"],
        "metrics_collection_interval": 60,
        "totalcpu": true
      },
      "mem": {
        "measurement": ["mem_used", "mem_free", "mem_cached", "mem_total", "mem_used_percent"],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": ["disk_used", "disk_free", "diskio_io_time", "disk_total"],
        "metrics_collection_interval": 60,
        "resources": ["*"]
      }
    }
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/syslog",
            "log_group_name": "syslog",
            "log_stream_name": "{instance_id}",
            "timestamp_format": "%b %d %H:%M:%S"
          },
          {
            "file_path": "/var/log/messages",
            "log_group_name": "messages",
            "log_stream_name": "{instance_id}",
            "timestamp_format": "%b %d %H:%M:%S"
          },
          {
            "file_path": "/var/log/cloud-init-output.log",
            "log_group_name": "cloud-init-logs",
            "log_stream_name": "{instance_id}",
            "timestamp_format": "%Y-%m-%d %H:%M:%S"
          }
        ]
      }
    }
  }
}
EOF
echo "[userdata.sh] Created CloudWatch Agent config file at: '$CW_AGENT_CONFIG_PATH/cloudwatch-agent.json'"

## Ativa o CloudWatch Agent
sudo amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c "file:$CW_AGENT_CONFIG_PATH/cloudwatch-agent.json" -s
echo "[userdata.sh] Done! CloudWatch Agent has been configured and started."

# Instalando Docker Engine utilizando APT
# https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository

echo "Starting Docker installation..."

## Adiciona a chave 'GPG' do Docker:
echo "Setting up Docker APT repository..."
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "Done! The Docker repository is now configured."

## Adiciona o repositório ao APT sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

## Instala os pacotes necessários para o Docker:
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

## Testando a instalação:
if ! docker --version > /dev/null 2>&1; then echo "Something went wrong! Docker isn't running."; exit 1; fi
if ! docker compose version > /dev/null 2>&1; then echo "Something went wrong! Docker compose isn't running."; exit 1; fi

echo "Done! The Docker is now installed."

# Configurando a inicialização do Docker e suas permissões (post install):
# https://docs.docker.com/engine/install/linux-postinstall/

## Atualiza as permissões:
echo "Setting up Docker permissions..."
sudo groupadd docker 2>/dev/null # ignore if group already exists
sudo usermod -aG docker $USER
#newgrp docker # activate the changes to groups
echo "Done! The Docker permissions is now configured."

## Inicia o serviço do Docker:
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
echo "Enabled Docker and Containerd services!"
echo "Use 'sudo systemctl status docker.service' to see the current status."

# Configuração do EFS:
echo "Setting up EFS, installing 'nfs-common'..."
sudo apt install nfs-common -y
sudo mkdir -p /mnt/efs
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport <EFS_IP>:/ /mnt/efs
echo "Done! The EFS is now configured at '/efs'"

# Cria e configura o arquivo 'compose.yaml':
PROJECT_PATH="/opt/wordpress"
mkdir -p "$PROJECT_PATH"  # create the directory

cat << EOF > "$PROJECT_PATH/compose.yaml"
services:
  wordpress:
    image: wordpress
    restart: always
    ports:
      - "80:80"
    environment:
      WORDPRESS_DB_HOST: <DB_HOST>
      WORDPRESS_DB_USER: <DB_USER>
      WORDPRESS_DB_PASSWORD: <DB_PASSWORD>
      WORDPRESS_DB_NAME: <DB_NAME>
    volumes:
      - "/mnt/efs/wordpress:/var/www/html"
EOF
echo "Compose file created at '$PROJECT_PATH/compose.yaml'!"

# Inicia o Docker compose
cd "$PROJECT_PATH"
docker compose -p wordpress up -d