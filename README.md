<h1 align="center">
    <img align="center" src="https://logospng.org/download/uol/logo-uol-icon-256.png" width="30" height="30" /> Compass UOL - DevSecOps
</h1>

<p align="center">Repositório para documentação e projetos do estágio de DevSecOps.</p>

### Projetos

- [Projeto Linux](./projetos/projeto-linux/README.md)
  - [Ambiente Linux no Windows](./projetos/projeto-linux/README.md#ambiente-linux-no-windows-wsl)
  - [Instalação e Monitoramento do NGINX](./projetos/projeto-linux/README.md#instalação-e-monitoramento-do-nginx)
  - [Testes e Validação](./projetos/projeto-linux/README.md#testes-e-validação)
- [Projeto Docker](./projetos/projeto-docker/README.md)
  - [Criação da **VPC**](./projetos/project-docker/1.vpc_e_subnets.md#criação-da-vpc);
  - [Criação das **Subnets**](./projetos/project-docker/1.vpc_e_subnets.md#criação-das-subnets);
  - [Criação do **Internet Gateway**](./projetos/project-docker/2.internet_gateway.md#criação-do-internet-gateway);
  - [Criação do **NAT Gateway**](./projetos/project-docker/3.nat_gateways.md#criação-dos-nat-gateways);
  - [Criação e Configuração das **Route Tables**](4.route_tables.md#criação-e-configuração-das-route-tables);]
  - [Criação e Configuração dos **Security Groups**](5.security_groups.md#criação-e-configuração-dos-security-groups);
  - [Criação do **EFS**](./projetos/project-docker/6.efs.md#criação-do-efs);
  - [Criação do **RDS**](./projetos/project-docker/7.rds.md#criação-do-rds-mysql);
  - [Criação do **Load Balancer**](./projetos/project-docker/8.load_balancer.md#criação-do-load-balancer);
  - [Criação do **EC2 (Template)**](./projetos/project-docker/9.ec2_template.md#criação-do-ec2-template);
  - [Criação e Configuração do **Auto Scaling Group**](./projetos/project-docker/10.auto_scaling_group.md#criação-e-configuração-do-auto-scaling-group).

### Documentação

- [Kubernetes Pods e Services](./docs/kubernetes/)
  - [Projeto Fleetman](./docs/kubernetes/fleetman-project/)
    - API ([Service](./docs/kubernetes/fleetman-project/api-gateway-service.yaml) / [Pod](./docs/kubernetes/fleetman-project/api-gateway-pod.yaml))
    - MongoDB ([Service](./docs/kubernetes/fleetman-project/mongodb-service.yaml) / [Pod](./docs/kubernetes/fleetman-project/mongodb-pod.yaml))
    - Position Simulator ([Pod](./docs/kubernetes/fleetman-project/position-simulator-pod.yaml))
    - Position Tracker ([Service](./docs/kubernetes/fleetman-project/position-tracker-service.yaml) / [Pod](./docs/kubernetes/fleetman-project/position-tracker-pod.yaml))
    - Queue ([Service](./docs/kubernetes/fleetman-project/queue-service.yaml) / [Pod](./docs/kubernetes/fleetman-project/queue-pod.yaml))
    - Webapp ([Service](./docs/kubernetes/fleetman-project/webapp-service.yaml) / [Pod](./docs/kubernetes/fleetman-project/webapp-pod.yaml))
- [Prometheus e Grafana](./docs/kubernetes/)
  - [Docker compose](./docs/prometheus-grafana/)
    - [Config do Prometheus](./docs/prometheus-grafana/prometheus/)
    - [Config do Grafana](./docs/prometheus-grafana/grafana/)
  - [Projeto feito em Go](./docs/prometheus-grafana/metrics-project/)
    - [main.go](./docs/prometheus-grafana/metrics-project/main.go)
