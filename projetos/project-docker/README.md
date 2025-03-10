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

- [Criação da **VPC**](1.vpc_e_subnets.md#criação-da-vpc);
- [Criação das **Subnets**](1.vpc_e_subnets.md#criação-das-subnets);
  - [Subnets Públicas](1.vpc_e_subnets.md#subnets-públicas);
  - [Subnets Privadas](1.vpc_e_subnets.md#subnets-privadas);
- [Criação do **Internet Gateway**](2.internet_gateway.md#criação-do-internet-gateway);
  - [Configuração do **Internet Gateway**](2.internet_gateway.md#configuração-do-internet-gateway);
- [Criação do **NAT Gateway**](3.nat_gateways.md#criação-dos-nat-gateways);
- [Criação e Configuração das **Route Tables**](4.route_tables.md#criação-e-configuração-das-route-tables);]
  - [Route Tables Públicas](4.route_tables.md#route-tables-públicas)
  - [Route Tables Privadas](4.route_tables.md#route-tables-privadas)
  - [Route Table Privada 1 (us-east-1a)](4.route_tables.md#route-table-privada-1-us-east-1a)
  - [Route Table Privada 2 (us-east-1b)](4.route_tables.md#route-table-privada-2-us-east-1b)
- [Criação e Configuração dos **Security Groups**](5.security_groups.md#criação-e-configuração-dos-security-groups);
  - [Security Group - Load Balancer](5.security_groups.md#security-group---load-balancer)
  - [Security Group - EC2](5.security_groups.md#security-group---ec2)
  - [Security Group - EFS](5.security_groups.md#security-group---efs)
  - [Security Group - RDS](5.security_groups.md#security-group---rds)
- [Criação do **EFS**](6.efs.md#criação-do-efs);
- [Criação do **RDS**](7.rds.md#criação-do-rds-mysql);
- [Criação do **Load Balancer**](8.load_balancer.md#criação-do-load-balancer);
- [Criação do **EC2 (Template)**](9.ec2_template.md#criação-do-ec2-template);
- [Criação e Configuração do **Auto Scaling Group**](10.auto_scaling_group.md#criação-e-configuração-do-auto-scaling-group).

---

<div align="center">

[Iniciar →](1.vpc_e_subnets.md#criação-da-vpc)

<div>
