# filecoin-chart

[![CircleCI](https://circleci.com/gh/openworklabs/filecoin-chart.svg?style=svg)](https://circleci.com/gh/openworklabs/filecoin-chart)

Filecoin chart is a helm chart for hosting Lotus Node clients. [Lotus](https://github.com/filecoin-project/lotus) is an implementation of the [Filecoin spec](https://filecoin-project.github.io/specs/).

## Goals

1. Deploy one or more instances of Lotus client nodes.
2. Expose Lotus node API's through HTTP endpoints.
3. Enable importing chain data for faster syncs.
4. Provide flexible configuration options to suit your needs.

For monitoring and graphing, see [filecoin-k8s](https://github.com/openworklabs/filecoin-k8s).
For customizing the Lotus Docker configuration, see [filecoin-docker](https://github.com/openworklabs/filecoin-docker).

This repository has not yet been used for managing Filecoin miners.

## Prerequisites

### Kubernetes cluster (required)

This is the only required prerequisite. The rest of the prerequisites are optionally enabled.

Information on [getting started](https://kubernetes.io/docs/setup/) with Kubernetes. For most use cases, we'd advise starting with Kubernetes running in the cloud. As far as we're aware, if you want to use this repository to run a Lotus miner node, you will need to use a bare metal install of Kubernetes, so you get access to a GPU.

### Minimum Machine Requirements

In our experience, we have had good results on Lotus testnet/2 using these settings:

```
requests:
    cpu: 1000m
    memory: 4Gi
limits:
    cpu: 3000m
    memory: 12Gi
```

These specs are subject to change, so use this as a jumping off point.

It can take a couple of tries to get the node synced with the network.

### NGINX Ingress Controller (optional)

By default, a Lotus node running inside a Kubernetes cluster is not exposed to the public. The NGINX Ingress Controller is one configuration option that, when enabled, can expose your Lotus node via an HTTP endpoint.

For more details on installation, see [NGINX Installation Guide](https://kubernetes.github.io/ingress-nginx/deploy/).

**Note** - NGINX Ingress Controller is _different_ from [NGINX Kubernetes Ingress Controller](https://www.nginx.com/products/nginx/kubernetes-ingress-controller/) (which we are not using). 

### Certbot (optional)

[Certbot](https://certbot.eff.org/) for handling certs and enabling HTTPS.

## Installation

The chart can be installed (and upgraded) via helm. To install the chart with the with the namespace `filecoin`, run these commands:

Clone this repository:
```shell
git clone https://github.com/openworklabs/filecoin-chart
cd filecoin-chart
```

Create a new `filecoin` namespace:

```shell
kubectl create ns filecoin
```

Deploy a new stateful set `node01` to the `filecoin` namespace:
```shell
helm upgrade --install --namespace filecoin -f values.yaml node01 .
```
The [values file](https://github.com/openworklabs/filecoin-chart/blob/master/values.yaml) contains all the configuration options.

## Configuration options

These are our emphasized config options. For a full list, see the [values file](https://github.com/openworklabs/filecoin-chart/blob/master/values.yaml).

| Parameter | Description | Default |
|-----------|-----------------------------------------|---------|
| `replicaCount` | The number of Lotus replicas to run | 1 |
| `image.repository` | Lotus Docker Image | `openworklabs/lotus` |
| `IPFS.enabled` | Enable IPFS on the pod | `false` |
| `Powergate.enabled` | Enable Powergate on the pod | `false` |
| `resources.ipfs.requests.cpu` | The amount of vCPU (IPFS).  | `<unset>` |
| `resources.ipfs.requests.memory` | The amount of memory (IPFS).  | `<unset>` |
| `resources.ipfs.limit.cpu` | The ceiling amount of vCPU (IPFS).  | `<unset>` |
| `resources.ipfs.limit.memory` | The ceiling amount of memory (IPFS).  | `<unset>` |
| `resources.powergate.requests.cpu` | The amount of vCPU (Powergate).  | `<unset>` |
| `resources.powergate.requests.memory` | The amount of memory (Powergate).  | `<unset>` |
| `resources.powergate.limit.cpu` | The ceiling amount of vCPU (Powergate).  | `<unset>` |
| `resources.powergate.limit.memory` | The ceiling amount of memory (Powergate).  | `<unset>` |
| `resources.lotus.requests.cpu` | The amount of vCPU (Lotus).  | `<unset>` |
| `resources.lotus.requests.memory` | The amount of memory (Lotus).  | `<unset>` |
| `resources.lotus.limit.cpu` | The ceiling amount of vCPU (Lotus).  | `<unset>` |
| `resources.lotus.limit.memory` | The ceiling amount of memory (Lotus).  | `<unset>` |
| `persistence.enabled` | Enable persistent volume.  | `true` |
| `persistence.ipfs.size` | Persistent volume storage size (IPFS).  | `"200Gi"` |
| `persistence.ipfs.storageClassName` | Storage provisioner (IPFS). | `gp2` |
| `persistence.powergate.size` | Persistent volume storage size (Powergate).  | `"200Gi"` |
| `persistence.powergate.storageClassName` | Storage provisioner (Powergate). | `gp2` |
| `persistence.lotus.size` | Persistent volume storage size (Lotus).  | `"200Gi"` |
| `persistence.lotus.storageClassName` | Storage provisioner (Lotus). | `gp2` |
| `secretVolume.enabled` | If you want to reuse token across installations. See [here](https://github.com/openworklabs/filecoin-chart/blob/master/README.md#Lotus-JWT) for more details. | `false` |

## Upgrading to a new version of Lotus

(todo) for now, if your question is urgent, file an Issue.

## Fast-sync

It is possible to deploy a node using a chain-data import to speed up the node's sync phase: (todo). FOr now, if your question is urgent, file an Issue. 

## Lotus JWT

If you need to do a full reinstall (uninstall chart, delete persistent volume, reinstall chart) of a Lotus node, the node's data will be erased. This means your node will lose its JWT, which will break existing clients relying on the API. To persist your Lotus JWT for reuse through multiple installations, enable `secretVolume.enabled`, and put the node's JWT into a secret:

```shell
## Cat node01's JWT into a file
kubectl -n filecoin exec -it node01-lotus-0 cat root/.lotus/token > token
## Take the file and put it into a secret
kubectl -n filecoin create secret generic lotus-token-secret --from-file=token=token
```

More information on generating a JWT for authenticating requests [here](https://docs.lotu.sh/en+api-scripting-support).

## License

This project is licensed under the [Apache 2.0](https://github.com/openworklabs/filecoin-chart/blob/master/LICENSE) license.
