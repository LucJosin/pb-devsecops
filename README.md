<h1 align="center">
    <img align="center" src="https://logospng.org/download/uol/logo-uol-icon-256.png" width="30" height="30" /> Compass UOL - DevSecOps
</h1>

<p align="center">Repositório para documentação e projetos do estágio de DevSecOps.</p>

### Projetos

- [Projeto Linux](./projetos/projeto-linux/README.md)
  - [Ambiente Linux no Windows](./projetos/projeto-linux/README.md#ambiente-linux-no-windows-wsl)
  - [Instalação e Monitoramento do NGINX](./projetos/projeto-linux/README.md#instalação-e-monitoramento-do-nginx)
  - [Testes e Validação](./projetos/projeto-linux/README.md#testes-e-validação)

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
