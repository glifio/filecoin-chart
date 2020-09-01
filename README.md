# filecoin-chart

[![CircleCI](https://circleci.com/gh/openworklabs/filecoin-chart.svg?style=svg)](https://circleci.com/gh/openworklabs/filecoin-chart)

Filecoin chart is a helm chart for hosting Lotus Node clients. [Lotus](https://github.com/filecoin-project/lotus) is an implementation of the [Filecoin spec](https://filecoin-project.github.io/specs/).

## Goals

1. Deploy one or more instances of Lotus client nodes.
2. Deploy additional software such as [IPFS](https://github.com/ipfs/ipfs) and [Powergate](https://github.com/textileio/powergate).
3. Expose Lotus, IPFS and Powergate APIs through HTTP endpoints.
4. Enable importing chain data for faster syncs.
5. Provide flexible configuration options to suit your needs.

For monitoring and graphing, see [filecoin-k8s](https://github.com/openworklabs/filecoin-k8s).
For customizing the Lotus Docker configuration, see [filecoin-docker](https://github.com/openworklabs/filecoin-docker).

This repository has not yet been used for managing Filecoin miners.

## Prerequisites

### Kubernetes cluster (required)

This is the only required prerequisite. The rest of the prerequisites are optionally enabled.

Information on [getting started](https://kubernetes.io/docs/setup/) with Kubernetes. For most use cases, we'd advise starting with Kubernetes running in the cloud. As far as we're aware, if you want to use this repository to run a Lotus miner node, you will need to use a bare metal install of Kubernetes, so you get access to a GPU.

#### Minimum Machine Requirements

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

### CSI Driver (optional)

When CSI driver is installed charts provides additional features:

1. Automatic creation of Lotus node snapshots
2. Automatic cleanup of existing snapshots with customizable retain number

**Note:** CSI driver should support snapshot feature. Our charts is currently supporting EBS CSI Driver by default with it's `ebs-sc` storage class, but one may override this class by setting `.Values.persistence.lotus.storageClassName` variable.

## Installation

The chart can be installed (and upgraded) via Helm. To install the chart with the with the namespace `filecoin`, run these commands:

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
| `replicaCount` | The number of Lotus replicas to run. | 1 |
| `image.repository` | Lotus Docker Image. | `openworklabs/lotus` |
| `IPFS.enabled` | Enable IPFS on the pod. | `false` |
| `Powergate.enabled` | Enable Powergate on the pod. | `false` |
| `serviceAccount.create` | Create service account. Must be enabled when enabling snapshot automation. | `false` |
| `serviceAccount.name` | Must be set when `serviceAccount.create` is `true`. Will be prefixed with release name. | `acc` |
| `ingress.enabled` | Enables ingress for this particular release | `true` |
| `ingress.host` | Defines DNS name that is used by NGINX to recognize valid requests | `node.glif.io` |
| `ingress.annotations` | Defines annotations for general ingress | See [values.yaml](values.yaml) |
| `ingress.<service>.enabled` | Enables ingress for particular service. | `true` |
| `ingress.<service>.annotations` | Defines annotations for particular service. Please read comments in `values.yaml` file to check the annotations that should be set to enable firewall-based access instead of JWT-based. | `<unset>` |
| `resources.<service>.requests.cpu` | The amount of vCPU (per service). | `<unset>` |
| `resources.<service>.requests.memory` | The amount of memory (per service). | `<unset>` |
| `resources.<service>.limit.cpu` | The ceiling amount of vCPU (per service). | `<unset>` |
| `resources.<service>.limit.memory` | The ceiling amount of memory (per service). | `<unset>` |
| `persistence.enabled` | Enable persistent volume.  | `true` |
| `persistence.<service>.size` | Persistent volume storage size (per service). | `"200Gi"` |
| `persistence.<service>.storageClassName` | Storage provisioner (per service). | `gp2` |
| `persistence.<service>.accessModes` | Persistent volume storage size (per service). | `"200Gi"` |
| `persistence.snapshots.*` | Described at [Snapshots](#snapshots) section |                                |
| `secretVolume.enabled` | If you want to reuse token across installations. See [here](https://github.com/openworklabs/filecoin-chart/blob/master/README.md#Lotus-JWT) for more details. | `false` |

## Snapshots

To start building Snapshots your persistent volume usually should be created using special CSI-compatible class. In most cases you can migrate your existing workloads, so please refer to the driver documentation for more details.

We are supporting [AWS EBS CSI driver](https://github.com/kubernetes-sigs/aws-ebs-csi-driver) out of the box. To create persistent volumes make sure you have the `ebs-sc` storage class installed. To perform installation go to the [examples folder](https://github.com/kubernetes-sigs/aws-ebs-csi-driver/tree/master/examples/kubernetes/snapshot) and complete the first step of instruction. After then set `persistence.snapshots.enabled` to `true` so the Charts will automatically create volumes of  the `ebs-sc` class. To override this behavior one can set `persistence.<service>.storageClassName` for each of the services. In this case Charts will create PV of the specified custom class.

To automate snapshot operations operator can set `persistence.snapshots.automation` parameters. If `creation` is set to `true` Charts will deploy a Cron job that will create snapshots on a daily basis.  If `deletion` is set to `true`  Charts will deploy a Cron job that will delete a snapshots for specific release if the number of snapshots is more than `retain.count`.

In case you want to create the new release based on existing snapshot one can set `persistence.snapshots.automation.restore.enabled` to `true`. In that case Lotus PV will be created based on snapshot named `persistence.snapshots.automation.restore.name`. Note that Snapshot should exist in the very same namespace where the release is deployed.

### Internal snapshots

One can setup `persistence.snapshots.uploadToIpfs.enabled` to `true` to make an automated cronjob that will take chain snapshots on a daily basis using `lotus chain export` command, and import the exported `.car` file into IPFS system. Note that IPFS must be running for `persistence.snapshots.uploadToIpfs.enabled` to take any effect.
Also `persistence.snapshots.uploadToIpfs.shareToGist` can be configured to automatically refresh the IPFS hash of the exported `.car` at the GitHub Gist. Note that the job will need an access to this Gist. To provide the job with the credentials use secret described in the [persistent secrets](#persistent-secret) section and add `ssh` key to Kubernetes Secret with base64-encoded private key content.

Note: You must use SSH URL in `persistence.snapshots.uploadToIpfs.shareToGist.address` so the `git push` command used inside of the job could use the provided ssh key to access the Gist.

## Persistent Secrets

### Lotus JWT

If you need to do a full reinstall (uninstall chart, delete persistent volume, reinstall chart) of a Lotus node, the node's data will be erased. This means your node will lose its JWT, which will break existing clients relying on the API. To persist your Lotus JWT for reuse through multiple installations, enable `secretVolume.enabled`, and put the node's JWT into a secret:

```shell
## Cat node01's JWT into a file
kubectl -n filecoin exec -it node01-lotus-0 cat root/.lotus/token > token
## Take the file and put it into a secret
kubectl -n filecoin create secret generic node01-lotus-secret --from-file=token=token
```

More information on generating a JWT for authenticating requests [here](https://docs.lotu.sh/en+api-scripting-support).

### SSH

You can also include your private `ssh` key into the installed persistent secret to allow Charts to authorize and push update about exported snapshot to the Gist when `persistence.snapshots.uploadToIpfs.shareToGist` is set. Use `ssh` as key in `<release_name>-lotus-secret` and base64 encoded private SSH key as value. 

## License

This project is licensed under the [Apache 2.0](https://github.com/openworklabs/filecoin-chart/blob/master/LICENSE) license.
