<h3 align="center">< Projeto Docker /></h3>

<h1 align="center">
    <img align="center" src="https://logospng.org/download/uol/logo-uol-icon-256.png" width="30" height="30" /> Compass UOL - DevSecOps
</h1>

Projeto Docker da trilha de **DevSecOps**:

## Objetivos

- Instalar e configurar o **Docker** em uma **EC2** (usando [User Data](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html));
- Configurar **Wordpress** com **Docker** compose;
- Utilizar o **RDS** (mysql);
- Utilizar o **EFS**;
- Utilizar o **Classic Load Balancer**.
- Utilizar o **NAT Gateway**.
- Utilizar o **Internet Gateway**.
- Utilizar o **Auto Scaling Group**.

> [!NOTE]
> Para facilitar, vamos utilizar o sufixo `-docker-pb` em todos os serviços.

## Diagrama completo

<details>
  <summary>Ver Diagrama</summary>

![Diagrama](./assets/PB-DEZ-DOCKER.svg)

</details>

## Requisitos

- Uma conta na **AWS**;
- Familiaridade com:
  - AWS:
    - RDS;
    - EFS;
    - EC2;
    - NAT Gateway;
    - Internet Gateway;
    - Auto Scaling Group;
  - Shell Script;
  - Docker;
  - Linux.

## Tópicos

- [Criação da **VPC**](#criação-da-vpc);
- [Criação das **Subnets**](#criação-das-subnets);
  - [Subnets Públicas](#subnets-públicas);
  - [Subnets Privadas](#subnets-privadas);
- [Criação do **Internet Gateway**](#criação-do-internet-gateway);
  - [Configuração do **Internet Gateway**](#configuração-do-internet-gateway);
- [Criação do **NAT Gateway**](#criação-dos-nat-gateways);
- [Criação e Configuração das **Route Tables**](#criação-e-configuração-das-route-tables);]
  - [Route Tables Públicas](#route-tables-públicas)
  - [Route Tables Privadas](#route-tables-privadas)
  - [Route Table Privada 1 (us-east-1a)](#route-table-privada-1-us-east-1a)
  - [Route Table Privada 2 (us-east-1b)](#route-table-privada-2-us-east-1b)
- [Criação e Configuração dos **Security Groups**](#criação-e-configuração-dos-security-groups);
  - [Security Group - Load Balancer](#security-group---load-balancer)
  - [Security Group - EC2](#security-group---ec2)
  - [Security Group - EFS](#security-group---efs)
  - [Security Group - RDS](#security-group---rds)
- [Criação do **EFS**](#criação-do-efs);
- [Criação do **RDS**](#criação-do-rds-mysql);
- [Criação do **Load Balancer**](#criação-do-load-balancer);
- [Criação do **EC2 (Template)**](#criação-do-ec2-template);
- [Criação e Configuração do **Auto Scaling Group**](#criação-e-configuração-do-auto-scaling-group).

## Criação da VPC

No Console da **AWS**, acesse a área de **VPC**. Clique `Create VPC`. Preencha com as seguintes configurações:

- **Name Tag**: `vpc-docker-pb`
- **IPv4 CIDR**: 10.0.0.0/16

## Criação das Subnets

Agora, para criar as **Subnets**, vá para o menu ao lado (dashboard do VPC) e clique em **Subnets** (Virtual private cloud > Subnets).

Vamos precisar de:

- **Subnet públicas**: 2 (Zonas us-east-1 e us-east-2)
  - Para o **Load Balancer** e **NAT Gateway**
- **Subnet privadas**: 2 (Zonas us-east-1 e us-east-2)
  - Para as instâncias **EC2** (com Wordpress)

Clique `Create subnet`. Preencha com as seguintes configurações:

### Subnets Públicas

Primeira **Subnet Pública**:

- **VPC ID**: Selecione a VPC criada anteriormente (`vpc-docker-pb`)
- **Subnet name**: `subnet-us-east-1a-public-docker-pb`
- **Availability Zone**: United States (N. Virginia) / **us-east-1a**
- **IPv4 subnet CIDR block**: 10.0.1.0/24 **(256 IPs)**

Segunda **Subnet Pública**:

- **VPC ID**: Selecione a VPC criada anteriormente (`vpc-docker-pb`)
- **Subnet name**: `subnet-us-east-1b-public-docker-pb`
- **Availability Zone**: United States (N. Virginia) / **us-east-1b**
- **IPv4 subnet CIDR block**: 10.0.3.0/24 **(256 IPs)**

### Subnets Privadas

Primeira **Subnet Privada**:

- **VPC ID**: Selecione a VPC criada anteriormente (`vpc-docker-pb`)
- **Subnet name**: `subnet-us-east-1a-private-docker-pb`
- **Availability Zone**: United States (N. Virginia) / **us-east-1a**
- **IPv4 subnet CIDR block**: 10.0.2.0/24 **(256 IPs)**

Segunda **Subnet Privada**:

- **VPC ID**: Selecione a VPC criada anteriormente (`vpc-docker-pb`)
- **Subnet name**: `subnet-us-east-1b-private-docker-pb`
- **Availability Zone**: United States (N. Virginia) / **us-east-1b**
- **IPv4 subnet CIDR block**: 10.0.4.0/24 **(256 IPs)**

> [!NOTE]
> Note que elas foram criadas em duas Zonas diferentes `us-east-1a` e `us-east-1b`.

## Criação do Internet Gateway

Para criar o **Internet Gateway**, vá para o menu ao lado (dashboard do VPC) e clique em **Internet Gateways**.

Clique `Create internet gateway`. Preencha com as seguintes configurações:

- **Name Tag**: `igw-docker-pb`

> [!WARNING]
> Não vamos esquecer de associar nosso **IGW** com a nossa **VPC**.

### Configuração do Internet Gateway

Após a criação do **Internet Gateway**, vamos precisar associar com a nossa **VPC**. No Banner VERDE clique em `Attach to a VPC` e selecione a **VPC (vpc-\<id\> - vpc-docker-pb)**.

## Criação dos NAT Gateways

Para criar os **NAT Gateways**, vá para o menu ao lado (dashboard do VPC) e clique em **NAT Gateways**.

Clique `Create NAT gateway`. Preencha com as seguintes configurações:

Primeiro **NAT** (10.0.1.0/24 - us-east-1a):

- **Name**: `nat-gw-us-east-1a-docker-pb`
- **Subnet**: `subnet-us-east-1a-public-docker-pb` (10.0.1.0/24)
- **Connectivity type**: Public
- **Elastic IP allocation ID**: (Clique em `Allocate Elastic IP`)

Segundo **NAT** (10.0.3.0/24 - us-east-1b):

- **Name**: `nat-gw-us-east-1b-docker-pb`
- **Subnet**: `subnet-us-east-1b-public-docker-pb` (10.0.3.0/24)
- **Connectivity type**: Public
- **Elastic IP allocation ID**: (Clique em `Allocate Elastic IP`)

## Criação e Configuração das Route Tables

Agora, vamos configurar as **Route Tables** para nossas subnets _Públicas_ e _Privadas_, e por consequência, nosso **NAT Gateway** e **Classic Load Balancer**

Para configurar as **Route Tables**, vá para o menu ao lado (dashboard do VPC) e clique em **Route Tables**, siga as próximas instruções.

### Route Tables Públicas

Clique `Create route table`. Preencha com as seguintes configurações:

- **Name**: `rtb-public-docker-pb`
- **VPC**: vpc-docker-pb

Após a criação da `rtb-public-docker-pb` clique em `Edit routes` e adicione uma nova regra com as seguintes configurações:

- **Destination**: 0.0.0.0/0
- **Target**: Internet Gateway
  - **Target Name**: `igw-docker-pb`

> [!WARNING]
> Não vamos esquecer de associar nosso **Route Table** com a nossas **Subnets** Públicas:

Clique em **Subnet associations** e **Edit subnet associations**, selecione nossas duas **Subnets** Públicas.

### Route Tables Privadas

Volte para o painel dos **Route Tables** e clique novamente em `Create route table`. Preencha com as seguintes configurações:

#### Route Table Privada 1 (us-east-1a)

- **Name**: `rtb-private-us-east-1a-docker-pb`
- **VPC**: vpc-docker-pb

Após a criação da `rtb-private-us-east-1a-docker-pb` clique em `Edit routes` e adicione uma nova regra com as seguintes configurações:

- **Destination**: 0.0.0.0/0
- **Target**: NAT Gateway
  - **Target Name**: `nat-gw-us-east-1a-docker-pb`

#### Route Table Privada 2 (us-east-1b)

- **Name**: `rtb-private-us-east-1b-docker-pb`
- **VPC**: vpc-docker-pb

Não vamos esquecer de associar nosso **Route Table** com a nossa **Subnet** Privada, clique em **Subnet associations** e **Edit subnet associations**, selecione `subnet-us-east-1a-private-docker-pb`.

Após a criação da `rtb-private-us-east-1b-docker-pb` clique em `Edit routes` e adicione uma nova regra com as seguintes configurações:

- **Destination**: 0.0.0.0/0
- **Target**: NAT Gateway
  - **Target Name**: `nat-gw-us-east-1b-docker-pb`

Não vamos esquecer de associar nosso **Route Table** com a nossa **Subnet** Privada, clique em **Subnet associations** e **Edit subnet associations**, selecione `subnet-us-east-1b-private-docker-pb`.

> [!TIP]
> Resumindo essa seção:
>
> - Criamos UMA route table pública (`rtb-public-docker-pb`) e assiciamos ela ao nosso **Internet Gateway**;
> - Criamos DUAS route tables privadas (`rtb-private-us-east-1a-docker-pb` e `rtb-private-us-east-1b-docker-pb`) e assiciamos ela aos nossos **NAT Gateways**;
>
> | Subnet  | Zona       | Bloco CIDR    |            Route Table             | Resumo                                                |
> | ------- | ---------- | ------------- | :--------------------------------: | ----------------------------------------------------- |
> | Pública | us-east-1a | `10.0.1.0/24` |       `rtb-public-docker-pb`       | Rota para: `0.0.0.0/0` <br> Via: **Internet Gateway** |
> | Pública | us-east-1b | `10.0.3.0/24` |       `rtb-public-docker-pb`       | Rota para: `0.0.0.0/0` <br> Via: **Internet Gateway** |
> | Privada | us-east-1a | `10.0.2.0/24` | `rtb-private-us-east-1a-docker-pb` | Rota para: `0.0.0.0/0` <br> Via: **NAT Gateway**      |
> | Privada | us-east-1b | `10.0.4.0/24` | `rtb-private-us-east-1b-docker-pb` | Rota para: `0.0.0.0/0` <br> Via: **NAT Gateway**      |

## Criação e Configuração dos Security Groups

Vamos criar e configurar os **Security Groups**, vá para o menu ao lado (dashboard do VPC) e clique em **Security Groups**.

Clique `Create security group`. Preencha com as seguintes configurações:

### Security Group - Load Balancer

- **Security group name**: `sgr-clb-us-east-1-docker-pb`
- **Description**: Security Group para Classic Load Balancer
- **VPC**: `vpc-docker-pb`
- **Tags**:
  - Name: `sgr-clb-us-east-1-docker-pb`

|   Rule   | Type | Protocol | Port Range |          Source           |
| :------: | :--: | :------: | :--------: | :-----------------------: |
| Inbound  | HTTP |   TCP    |     80     | 0.0.0.0/0 (Anywhere-IPV4) |
| Outbound | HTTP |   TCP    |     80     | 0.0.0.0/0 (Anywhere-IPV4) |

### Security Group - EC2

- **Security group name**: `sgr-ec2-us-east-1-docker-pb`
- **Description**: Security Group para EC2
- **VPC**: `vpc-docker-pb`
- **Tags**:
  - Name: `sgr-ec2-us-east-1-docker-pb`

|   Rule   |    Type    | Protocol | Port Range |          Source           |
| :------: | :--------: | :------: | :--------: | :-----------------------: |
| Inbound  |    HTTP    |   TCP    |     80     |       Load Balancer       |
| Outbound | All Trafic |   All    |    All     | 0.0.0.0/0 (Anywhere-IPV4) |

### Security Group - EFS

- **Security group name**: `sgr-efs-us-east-1-docker-pb`
- **Description**: Security Group para EFS
- **VPC**: `vpc-docker-pb`
- **Tags**:
  - Name: `sgr-efs-us-east-1-docker-pb`

|   Rule   |    Type    | Protocol | Port Range | Source |
| :------: | :--------: | :------: | :--------: | :----: |
| Inbound  |    NFS     |   TCP    |    2049    |  EC2   |
| Outbound | All Trafic |   All    |    All     |  EC2   |

### Security Group - RDS

- **Security group name**: `sgr-rds-us-east-1-docker-pb`
- **Description**: Security Group para RDS
- **VPC**: `vpc-docker-pb`
- **Tags**:
  - Name: `sgr-rds-us-east-1-docker-pb`

|   Rule   |     Type     | Protocol | Port Range | Source |
| :------: | :----------: | :------: | :--------: | :----: |
| Inbound  | MYSQL/Aurora |   TCP    |    3306    |  EC2   |
| Outbound |     ---      |   ---    |    ---     |  ---   |

## Criação do EFS

Vamos criar e configurar o **Elast File System (EFS)**, vá para o campo de pesquisa (ao topo), digite e selecione **EFS**.

Clique `Create file system` e `Customize`. Vamos preencher com as seguintes configurações:

1. Step 1 - File System Settings:

- **Name**: `efs-docker-pb`.

2. Step 2 - Network Access:

- **Virtual Private Cloud (VPC)**: `vpc-docker-pb`
- **Mount targets**:

| Availability zone |               Subnet ID               | IP address |       Security groups       |
| :---------------: | :-----------------------------------: | :--------: | :-------------------------: |
|    us-east-1a     | `subnet-us-east-1a-private-docker-pb` |    ---     | sgr-efs-us-east-1-docker-pb |
|    us-east-1b     | `subnet-us-east-1b-private-docker-pb` |    ---     | sgr-efs-us-east-1-docker-pb |

3. Step 3 - File System Policy:

- Clique em **Next**.

4. Step 4 - Review and Create:

- Clique em **Create**.

> [!TIP]
> Após a criação do **EFS**, clique no ID e procure pelo botão "Attach" e copie o comando abaixo de "Using the NFS client".
>
> Vamos utilizar esse comando no script!

## Criação do RDS (MySQL)

Vamos criar e configurar o **RDS (MySQL)**, vá para o campo de pesquisa (ao topo), digite e selecione **RDS**.

Clique `Create database`. Vamos preencher com as seguintes configurações:

- **Engine options**:
  - **Engine type**: MySQL
  - **Engine version**: 8.0.40
- **Templates**: Free Tier
- **Availability and durability**: Single-AZ DB instance deployment (1 instance)
- **Settings**:
  - **DB instance identifier**: wordpress-mysql
  - **Master username**: admin
  - **Credentials management**: Self managed (com **Auto generate password**)
- **Instance configuration**:
  - **Instance**: db.t3.micro
- **Connectivity**:
  - **Virtual private cloud (VPC)**: `vpc-docker-pb`
  - **VPC security group (firewall)**: Choose existing
  - **Existing VPC security groups**: `sgr-rds-us-east-1-docker-pb`
  - **Availability Zone**: No Preference
- **Tags**:
  - Name: rds-mysql-docker-pb
- **Additional configuration**:
  - **Initial database name**: wordpress

> [!WARNING]
>
> 1. O processo de criação pode levar **2~10 minutos**!
> 2. Vamos salvar as informações após criar o banco de dados!!
> 3. NÃO SE ESQUEÇA DE SALVAR AS INFORMAÇOES, NÃO SERÁ POSSÍVEL ACESSAR DEPOIS.

## Criação do Load Balancer

Vamos criar e configurar o **Load Balancer**, vá para o campo de pesquisa (ao topo), digite e selecione **Load Balancer** (EC2 Feature).

Clique `Create load balancer`. Vamos preencher com as seguintes configurações:

- **Load balancer types**:
  - Classic Load Balancer -> Create
- **Basic configuration**:
  - **Load balancer name**: `clb-docker-pb`
  - **Scheme**: Internet-facing
- **Network mapping**:
  - **VPC**: `vpc-docker-pb`
  - **Availability Zones and subnets**:
    - us-east-1a (`subnet-us-east-1a-public-docker-pb`)
    - us-east-1b (`subnet-us-east-1b-public-docker-pb`)
- **Security groups**: `sgr-clb-us-east-1-docker-pb`
- **Health checks**:
  - **Ping target**:
    - **Ping path**: /wp-admin/install.php
- **Load balancer tags**:
  - Name: clb-docker-pb

> [!NOTE]
> O Health Check vai validar no arquivo **/wp-admin/install.php**, porém é recomendado utilizar algum plugin para criação de um Health Check mais funcional ou criar um você mesmo:
>
> <details>
>  <summary>health-check.php</summary>
>
> ```php
> <?php
> require_once 'wp-load.php';
>
> $status = 200;
> $message = 'OK';
>
> // Verificar se o WordPress está instalado
> if (function_exists('is_blog_installed') && is_blog_installed()) {
>     // Verificar conexão com o banco de dados
>     global $wpdb;
>     if (!$wpdb || !$wpdb->check_connection()) {
>         $status = 500;
>         $message = 'Erro: Falha na conexão com o banco de dados.';
>     }
> } else {
>     $status = 500;
>     $message = 'Erro: WordPress não instalado.';
> }
>
> http_response_code($status);
> echo $message;
> ?>
> ```
>
> Check the function: [is_blog_installed()](https://developer.wordpress.org/reference/functions/is_blog_installed/)
>
> </details>

## Criação do EC2 (Template)

Nessa seção vamos criar um **Launch Template** para as nossas instâncias **EC2**, vá para o menu ao lado e clique em **Launch Templates**.

Clique `Create launch template`. Vamos preencher com as seguintes configurações:

- **Launch template name**: `wordpress-lt-docker-pb`
- **Template version description**: Primeira versão do template de wordpress usando Docker
- **Template tags**:
  - Name: wordpress-lt-docker-pb
- **Launch template contents**
  - **Application and OS Images (Amazon Machine Image)**: Ubuntu
- **Instance type**: t2.micro (Free Tier)
- **Key pair (login)**
  - Create new key pair **(Salve em um lugar fácil de lembrar)**
    - Key pair name: kp-wordpress-lt-docker-pb
    - Key pair type: RSA (.pem)
- **Network settings**
  - **Subnet**: Don't include in launch template
  - **Firewall (security groups)**:
    - Select existing security group (`sgr-ec2-us-east-1-docker-pb`)
- **Resource tags**
  - Name: \<PB_NAME\>
  - CostCenter: \<PB_COSTCENTER\>
  - Project: \<PB_PROJECT\>
- **Advanced details**:
  - **User data**: [Utilize o arquivo userdata.sh](./userdata.sh) (Troque as informações do EFS e WORDPRESS_DB\_\*)

> [!WARNING]
>
> 1. Só é nessário utilizar os **Resources Tags** se estiver utilizando uma conta do estágio!
> 2. Troque as informações do EFS e WORDPRESS_DB\_\* dentro do **userdata.sh**

## Criação e Configuração do Auto Scaling Group

Nessa seção vamos criar um **Auto Scaling Group** para as nossas instâncias **EC2**, vá para o menu ao lado e clique em **Auto Scaling Group**.

Clique `Create Auto Scaling group`. Vamos preencher com as seguintes configurações:

1. Step 1

- **Auto Scaling group name**: `asg-docker-pb`
- **Launch template**: `wordpress-lt-docker-pb`
- Next

2. Step 2

- **Network**:
  - **VPC**: `vpc-docker-pb`
  - **Availability Zones and subnets**: `subnet-us-east-1a-private-docker-pb` e `subnet-us-east-1b-private-docker-pb`
  - **Availability Zone distribution**: Balanced best effort

3. Step 3

- **Load balancing**: Attach to an existing load balancer
- **Attach to an existing load balancer**:
  - Choose from Classic Load Balancers
    - `clb-docker-pb`
  - **Health checks**:
    - Selecione: Turn on Elastic Load Balancing health checks (Recommended)
- Next

4. Step 4

- **Group size**:
  - **Desired capacity type**: 2
- **Scaling**:
  - **Scaling limits**:
    - Min desired capacity: 2
    - Max desired capacity: 4
  - **Automatic scaling**:
    - **Target tracking scaling policy**:
      - Scaling policy name: Target Tracking Policy
      - Metric type: Average CPU utilization
      - Target value: 50
  - **Instance maintenance policy**: No Policy
  - **Additional capacity settings**:
    - **Capacity Reservation preference**: Default
- Next

5. Step 5

- Next

6. Step 6

- **Tags**:
  - Name: asg-docker-pb
- Next

Para finalizar, clique em `Create Auto Scaling group`.

## Referências

- https://cjrequena.com/2020-06-05/aws-naming-conventions-en
