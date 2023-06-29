
<p align="center">
  <a href="https://api.node.glif.io/" title="Glif Node Hosting">
    <img src="./png/glif-protofire-logo.png" alt="Glif-Protofire-logo" width="244" />
  </a>
</p>

<h1 align="center">filecoin-charts</h1>

<p align="center">
	<a href="https://filecoinproject.slack.com/archives/C023K7D9GAX">
		<img src="https://img.shields.io/badge/Contact_Us-AA_AA?style=for-the-badge&logo=slack&logoColor=white" />
	</a>
	<a href="https://hub.docker.com/r/glif/lotus/tags">
		<img src="https://img.shields.io/badge/Docker_hub-IMAGES_AA?style=for-the-badge&logo=docker&logoColor=white&color=118df2" />
	</a>
	<a href="https://github.com/openworklabs/filecoin-chart/blob/master/LICENSE">
		<img src="https://img.shields.io/badge/Apache_2.0-_AA?style=for-the-badge&logo=apache&logoColor=white&color=11c5f2" />
	</a>
	<a href="https://discord.gg/5qsJjsP3Re">
		<img src="https://img.shields.io/badge/Join_Us-_AA?style=for-the-badge&logo=discord&logoColor=white&color=af10f3" />
	</a>
	<br />
</p>

## About

This repository is managed by <a href="https://protofire.io">Protofire</a>.

Filecoin chart is a Helm chart for hosting Lotus Nodes. [Lotus](https://github.com/filecoin-project/lotus) is an implementation of the [Filecoin spec](https://filecoin-project.github.io/specs/).


## Summary
The Chart can do the following:
- Deploy Lotus RPC nodes.
- Expose Lotus through HTTP endpoints.
- Enable importing chain snapshots.
- Provide flexible configuration options to suit your needs.


For customizing the Lotus Docker configuration, see [filecoin-docker](https://github.com/openworklabs/filecoin-docker)


## Installation

#### The chart can be installed (and upgraded) via Makefile

Before running any commands provided by the [Makefile](Makefile), you have to specify the build arguments.

- **NODE** is the name of the  values file located at *values/ENV/NAMESPACE/NODE.yaml* (and consequently the Helm release name) that you want to deploy.
- **ENV** is a subfolder of the values folder (conceptually that’s an environment, e.g. dev or mainnet).
- **NAMESPACE** is a subfolder of the ENV folder (conceptually that’s a Kubernetes namespace where you want to deploy the release).

Example:
````
- NODE = api-read-master
- ENV = mainnet 
- NAMESPACE = network
````

Configure the deployment options through the [values](values.yaml) file and deploy the Chart:

```shell
make nodeInstall
```

##### The Makefile provides the following commands

| Command             | Description                                                                        |
|---------------------|------------------------------------------------------------------------------------|
| make nodeInstall    | Install or upgrade the Helm release.                                               |
| make nodeReinit     | Delete the previously installed Helm release and deploys the new one from scratch. | 
| make nodeDelete     | Delete the Helm release.                                                           |
| make nodeDeleteFull | Delete the Helm release and also the persistent volume claims associated with it.  |
| make diff           | Run helm diff against the nodeInstall command. Requires the helm diff plugin.<br/> Refer to the official helm diff documentation for more detail.                          |



## Prerequisites

####  Kubernetes cluster (required)

Information on [getting started](https://kubernetes.io/docs/setup/) with Kubernetes. For most use cases, we'd advise starting with Kubernetes running in the cloud.

#### Minimum Machine Requirements

Refer to the official Lotus documentation for the [minimal system requirements](https://lotus.filecoin.io/lotus/install/prerequisites/). In our experience you may want to set these values to almost the full capacity of the host node. Adjust the `LOTUS_FVM_CONCURRENCY` environment variable for better performance (refer to the [environment variables](https://lotus.filecoin.io/lotus/configure/ethereum-rpc/#environment-variables) section of the official documentation).


### Connectivity

By default the Lotus nodes are not exposed to the Internet. You can use any ingress controller of your choice for this purpose.
We at Glif use the Kong Ingress Controller (refer to the official [Kong documentation](https://docs.konghq.com/kubernetes-ingress-controller/latest/). You can find our code examples [here](https://github.com/glifio/filecoin-iac/blob/main/k8s/konghq.tf).

#### CSI Driver (optional)

We create persistent volumes through the ebs-cs storage class configured via the EBS CSI Driver. That allows the Chart to create persistent volumes in Kubernetes backed by EBS volumes of AWS.
The CSI Driver is configured separately (refer to this repository for [code examples](https://github.com/glifio/filecoin-iac/blob/main/k8s/ebs_csi_driver.tf)).


## Configuration variables for stateful set

| Parameter                          | Description                                                                                                                                                                                                                       | Default                                                                                                                         |
|------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------|
| lotusStsCreate                     | Create the Lotus statefulset if true.                                                                                                                                                                                             | `true`                                                                                                                          |
| lotusStsLabels                     | A dictionary of the statefulset labels. Can be used as a service selector to provide a universal endpoint to the pods.                                                                                                            | `app: lotus-node-app`<br/>`release: stable`                                   |
| lotusStsReplicas                   | The replicas number for the statefulset to create.                                                                                                                                                                                | `1 `                                                                                                                            |
| nodeSelector                       | Constraints for scheduling pods to nodes.                                                                                                                                                                                         | `{}`                                                                                                                            |
| lotusVolume.hostPath.path          | Path on the local disk that’s represented in the container as `INFRA_LOTUS_HOME`.                                                                                                                                                 | `/nvme/disk`                                                                                                                    | 
| lotusVolume.hostPath.enabled       | If true, the `vol-lotus` volume is mounted as the ` /nvme/disk` path from the local disk.                                                                                                                                         | `true`                                                                                                                          |
| InitContainerPermissions           | If true, create an InitContainer that creates default folders (for lotus and for snapshots) and sets filesystem permissions.                                                                                                      | `true`                                                                                                                          |
| downloadSnapshot.enabled           | If true, create an InitContainer that downloads the chain snapshot.                                                                                                                                                               | `true`                                                                                                                          |
| downloadSnapshot.unpack            | If true,unpack  the downloaded snapshot and copy it  to the  `$SNAPSHOTURL` path.                                                                                                                                                 | `true`                                                                                                                          |
| downloadSnapshot.checkLedger       | If true, exit if the `INFRA_LOTUS_HOME/.lotus` directory exists.<br/> The existence of this directory means that lotus already has chainstate and the snapshot import is not required.                                            | `true `                                                                                                                         |
| downloadSnapshot.dependecies.aria2 | Aria2 version. Used for reliable download of the snapshot.                                                                                                                                                                        | `1.36.0-r1`                                                                                                                     |
| downloadSnapshot.dependecies.zstd  | Zstd version. Used for unpacking the ZST snapshots.                                                                                                                                                                               | `1.5.5-r0`                                                                                                                      |
| lotusEnv.DOWNLOAD_FROM             | Downloads snapshot from the path.                                                                                                                                                                                                 | "https://snapshots.mainnet.filops.net/minimal/latest.zst"<br/> "https://snapshots.calibrationnet.filops.net/minimal/latest.zst" |
| LotusEnv.SNAPSHOTURL               | Path in the container’s filesystem where copies unpacked snapshot                                                                                                                                                                 | `/home/lotus_user/snapshot/latest.car`                                                                                          |
| lotusContainer.image               | Lotus Docker image.                                                                                                                                                                                                               | `glif/lotus:1.20.3-calibnet-arm-custom `                                                                                        |
| lotusContainer.command             | Entrypoint of the Lotus container (refer to the [filecoin-docker](https://github.com/glifio/filecoin-docker) repo for more details).                                                                                              | `["/etc/lotus/docker/run"]`                                                                                                     |
| lotusContainer.preStopCommand      | Delete the `$INFRA_LOTUS_HOME/.lotus/sync-complete` if the container stops. Refer to the [filecoin-docker](https://github.com/glifio/filecoin-docker) repo for more details.                                                      | `["/bin/sh","-c","rm -f $INFRA_LOTUS_HOME/.lotus/sync-complete"]`                                                               |
| livenessProbe.enabled              | If true, livenessProbe runs.                                                                                                                                                                                                      | `true`                                                                                                                          |
| livenessProbe.initialDelaySeconds  | The field tells the kubelet that it should wait 600 seconds before performing the first probe.                                                                                                                                    | `600`                                                                                                                           |
| livenessProbe.periodSeconds        | The field specifies that the kubelet should perform a liveness probe every 20 seconds.                                                                                                                                            | `20`                                                                                                                            |
| livenessProbe.successThreshold     | Minimum consecutive successes for the probe to be considered successful after having failed.                                                                                                                                      | `1`                                                                                                                             |
| livenessProbe.timeoutSeconds       | Number of seconds after which the probe times out.                                                                                                                                                                                | `20`                                                                                                                            |
| readinessProbe.enabled             | If true, ReadinessProbe runs.                                                                                                                                                                                                     | `true`                                                                                                                          |
| readinessProbe.command             | To perform a probe, the kubelet executes the script in the target container (refer to the [filecoin-docker/sctipts/healthcheck](https://github.com/glifio/filecoin-docker/blob/master/scripts/healthcheck) file for more details. | `["healthcheck"]`                                                                                                               |
| readinessProbe.initialDelaySeconds | Number of seconds after the container has started before readiness probes are initiated.                                                                                                                                          | `600`                                                                                                                           |
| readinessProbe.periodSeconds       | How often (in seconds) to perform the probe.                                                                                                                                                                                      | `60`                                                                                                                            |
| readinessProbe.successThreshold    | Minimum consecutive successes for the probe to be considered successful after having failed.                                                                                                                                      | `1`                                                                                                                             |
| readinessProbe.timeoutSeconds      | Number of seconds after which the probe times out.                                                                                                                                                                                | `3`                                                                                                                             |
| startupProbe.enabled               | If true, StartupProbe runs.                                                                                                                                                                                                       | `true`                                                                                                                          |
| startupProbe.failureThreshold      | After a probe fails times in a row, Kubernetes considers that the overall check has failed: the container is not ready/healthy/live.                                                                                              | `1000`                                                                                                                          |
| startupProbe.periodSeconds         | How often (in seconds) to perform the probe.                                                                                                                                                                                      | `200`                                                                                                                           |
| startupProbe.successThreshold      | Minimum consecutive successes for the probe to be considered successful after having failed. Must be 1 for liveness and startup Probes.                                                                                           | `1`                                                                                                                             |
| startupProbe.timeoutSeconds        | Number of seconds after which the probe times out. Defaults to 1 second.                                                                                                                                                          | `10`                                                                                                                            |
| lotusVolumeAccessModes             | The volume can be mounted as read-write by a single node.<br/>ReadWriteOnce access mode can allow multiple pods to access the volume when the pods are running on the same node.                                                  | `ReadWriteOnce`                                                                                                                 |
| lotusVolumeSize                    | The volume size of Lotus.                                                                                                                                                                                                         | `50Gi`                                                                                                                          |
| lotusVolumeStorageClass            | Amazon EBS provides the volume type for our storage.                                                                                                                                                                              | `ebs-sc-gp2`                                                                                                                    |
| createLotusService                 | Create the Lotus service if true.                                                                                                                                                                                                 | `true`                                                                                                                          |
| lotusServiceAnnotations            | Set of the specify annotations.                                                                                                                                                                                                   | `prometheus.io/scrape: "true"`<br/> `prometheus.io/port: "1234"`<br/> `prometheus.io/path: "/debug/metrics"`                      |
| createCache                        | Create the cache deployment if true.                                                                                                                                                                                              | `false`                                                                                                                                                                                                                             |
| cacheImageRepository               | Cache image.                                                                                                                                                                                                                      |`protofire/filecoin-rpc-proxy:0.0.3`|
| cacheDeploymentReplicas            | Indicates how many replicas should be in the deployment                                                                                                                                                                           | `2`                                  |
| cacheRequestsCpu                   | The amount of CPU cache pod requests on schedule.                                                                                                                                                                                 | `500m`                                                                                                                                                                                                                            |
| cacheRequestsMemory                | The amount of memory cache pod requests on schedule.                                                                                                                                                                              | `1Gi`                                                                                                                                                                                                                             |
| cacheCpuLimit                      | The amount of CPU cache pod is limited to.                                                                                                                                                                                        | `3000m`                                                                                                                                                                                                                           |
| cacheMemoryLimit                   | The amount of memory cache pod is limited to.                                                                                                                                                                                     | `3Gi`                                                                                                                                                                                                                             |


## Usage example 
````yaml
nodeSelector:
nodeGroupName: group16
assign_to_space00_07_nodes: allow_any_pods

lotusEnv:
LOTUS_VM_ENABLE_TRACING: "true"
INFRA_IMPORT_SNAPSHOT: "true"
INFRA_LOTUS_GATEWAY: "true"
INFRA_CLEAR_RESTART: "false"
DOWNLOAD_FROM: "https://snapshots.mainnet.filops.net/minimal/latest.zst"
SNAPSHOTURL: /home/lotus_user/snapshot/latest.car


lotusContainer:
image: glif/lotus:v1.23.0-custom-mainnet-arm64-test

lotusRequestsCpu: 12
lotusRequestsMemory: 80Gi

lotusCpuLimit: 25
lotusMemoryLimit: 120Gi

createLotusService: false
````
