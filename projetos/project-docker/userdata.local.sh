#!/usr/bin/env bash

# Atualiza os pacotes
echo "Updating packages..."
sudo apt update && sudo apt upgrade -y
echo "Updated packages!"

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
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

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
newgrp docker # activate the changes to groups
echo "Done! The Docker permissions is now configured."

## Inicia o serviço do Docker:
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
echo "Enabled Docker and Containerd services!"
echo "Use 'sudo systemctl status docker.service' to see the current status."

# Cria e configura o arquivo 'compose.yaml':
PROJECT_PATH="/opt/wordpress"
mkdir -p "$PROJECT_PATH"  # create the directory

cat << EOF > "$PROJECT_PATH/compose.yaml"
services:
  wordpress:
    image: wordpress:latest
    ports:
      - "80:80"
    environment:
      WORDPRESS_DB_HOST: mysql
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: wordpress
      WORDPRESS_DB_NAME: wordpress
    depends_on:
      - mysql

  mysql:
    image: mysql:8.4.4
    ports:
      - "3306:3306"
    environment:
      MYSQL_ROOT_PASSWORD: wordpress
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: wordpress
    expose:
      - 3306
EOF
echo "Compose file created at '$PROJECT_PATH/compose.yaml'!"

# Inicia o Docker compose
cd "$PROJECT_PATH"
docker compose -p wordpress up -d