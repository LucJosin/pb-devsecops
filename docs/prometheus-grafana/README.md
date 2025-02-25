<h3 align="center">< Docs - Prometheus e Grafana /></h3>

<h1 align="center">
    <img align="center" src="https://logospng.org/download/uol/logo-uol-icon-256.png" width="30" height="30" /> Compass UOL - DevSecOps
</h1>

Documentação da sprint de **DevSecOps** com Prometheus e Grafana.

## Arquivos

- [Docker compose](./)
  - [Config do Prometheus](./prometheus/)
  - [Config do Grafana](./grafana/)
- [Projeto feito em Go](./metrics-project/)
  - [main.go](./metrics-project/main.go)

### Projeto Metrics

Passo a passo simplificado para rodar o projeto **metrics** e o **prometheus e grafana** com docker.

#### Requisitos (Linux)

- Go (min 1.22)
- Docker

#### Inicializando o projeto

```
cd ./metrics-project/
```

Se for a primeira vez, vai precisar das depencências:

```
go mod tidy
```

Inicializando o servidor:

```
go run main.go
```

#### Navegador

Você vai precisar do seu ip local:

```bash
ifconfig # No Linux
```

Adicione a porta **4689** e abra no seu navegador. Exemplo:

> 192.168.X.X:4689/metrics

> [!NOTE]
> Antes de ir para o próximo passo, modifique o ip em `scrape_configs.job_name.static_configs.targets` do [arquivo de configuração do prometheus](./prometheus/prometheus.yaml).

#### Prometheus e Grafana

```bash
docker compose up -d # Primeira vez
```

```bash
docker compose start # Depois de um 'docker compose stop'
```
