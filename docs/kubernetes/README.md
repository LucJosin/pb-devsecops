<h3 align="center">< Docs - Docker e Kubernetes /></h3>

<h1 align="center">
    <img align="center" src="https://logospng.org/download/uol/logo-uol-icon-256.png" width="30" height="30" /> Compass UOL - DevSecOps
</h1>

Documentação da sprint de **DevSecOps** com Docker, Containers e Kubernetes.

## Arquivos

- [Kubernetes Pods e Services](./)
- [Projeto Fleetman](./fleetman-project/)
  - API ([Service](./fleetman-project/api-gateway-service.yaml) / [Pod](./fleetman-project/api-gateway-pod.yaml))
  - MongoDB ([Service](./fleetman-project/mongodb-service.yaml) / [Pod](./fleetman-project/mongodb-pod.yaml))
  - Position Simulator ([Pod](./fleetman-project/position-simulator-pod.yaml))
  - Position Tracker ([Service](./fleetman-project/position-tracker-service.yaml) / [Pod](./fleetman-project/position-tracker-pod.yaml))
  - Queue ([Service](./fleetman-project/queue-service.yaml) / [Pod](./fleetman-project/queue-pod.yaml))
  - Webapp ([Service](./fleetman-project/webapp-service.yaml) / [Pod](./fleetman-project/webapp-pod.yaml))

### Projeto Fleeman

Passo a passo simplificado para consequir rodar o projeto **fleetman** com kubernetes.

#### Requisitos (Linux)

- Docker
- Minikube
- Kubectl

#### Minikube

```
minikube start
```

#### Inicializando o projeto

```
cd ./fleetman-project && kubectl apply -f .
```

#### Webapp

Acesso o webapp utilizando o ip do **minikube**:

```
minikube ip
```

Adicione a porta **30080** e abra no seu navegador. Exemplo:

> 192.168.X.X:30080
