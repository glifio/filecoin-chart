
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
Glif helm chart are managed by <a href="https://protofire.io">Protofire</a>.

Filecoin chart is a helm chart for hosting Lotus Node clients. [Lotus](https://github.com/filecoin-project/lotus) is an implementation of the [Filecoin spec](https://filecoin-project.github.io/specs/).

## Summary
Expects of the installation of our charts:
1. Deploy one or more instances of Lotus client nodes.
2. Deploy additional software such as [IPFS](https://github.com/ipfs/ipfs).
3. Expose Lotus, IPFS APIs through HTTP endpoints.
4. Enable importing chain data for faster syncs.
5. Provide flexible configuration options to suit your needs.

For monitoring and graphing, see [filecoin-k8s](https://github.com/openworklabs/filecoin-k8s).
For customizing the Lotus Docker configuration, see [filecoin-docker](https://github.com/openworklabs/filecoin-docker)

This repository has not yet been used for managing Filecoin miners.


## Installation
- The chart can be installed (and upgraded) via Helm.
-  The chart can be installed (and upgraded) via Makefile.


#### The chart can be installed (and upgraded) via Helm
To install the chart with the namespace `filecoin`, run these commands:

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

The [values file](https://github.com/openworklabs/filecoin-chart/blob/master/values.yaml) contains all the configuration options.
```shell
helm upgrade --install --namespace filecoin -f values.yaml node01 .
```


#### The chart can be installed (and upgraded) via Makefile

Before running any commands provided by the [Makefile](Makefile), you have to specify the build arguments.

- **NODE** is the name new pod that you want to creation, value(name your yaml file).
- **ENV** is the cluster environment where you want to deploy a pod, value (production env - mainnet; dev env - dev).
- **NAMESPACE** is the Kubernetes namespace where you want to deploy a pod, value (network, monitoring, logging).

Example:
````
- NODE = api-read-master
- ENV = mainnet 
- NAMESPACE = network
````
Deploy a new stateful set:\
The [values file](https://github.com/openworklabs/filecoin-chart/blob/master/values.yaml) contains all the configuration options.

```shell
make nodeInstall
```

##### The Makefile provides the commands

| run command         | Description                                                                        |
|---------------------|------------------------------------------------------------------------------------|
| make nodeInstall    | The pod is updated and redeployed with the same `Statefulset`.                     |
| make nodeReinit     | The pod is removed with the current `Statefulset` and redeployed with the new one. | 
| make nodeDelete     | The pod is deleted with the Statefulset without pvc volume.                        |
| make nodeDeleteFull | The pod is removed with the Statefulset and is deleted pvc volume.                 |
| make diff           | Output between the current pod state and the new  state.                           |



## Prerequisites

####  Kubernetes cluster (required)

This is the only required prerequisite. The rest of the prerequisites are optionally enabled.

Information on [getting started](https://kubernetes.io/docs/setup/) with Kubernetes. For most use cases, we'd advise starting with Kubernetes running in the cloud. As far as we're aware, if you want to use this repository to run a Lotus miner node, you will need to use a bare metal install of Kubernetes, so you get access to a GPU.

#### Minimum Machine Requirements

In our experience, we have had good results on Lotus mainnet using these settings:

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

#### CSI Driver (optional)


When CSI driver is installed charts provides additional features:


1. Automatic creation of Lotus node snapshots

2. Automatic cleanup of existing snapshots with customizable retain number


**Note:** CSI driver should support snapshot feature. Our charts is currently supporting EBS CSI Driver by default with it's `ebs-sc` storage class, but one may override this class by setting `.Values.persistence.lotus.storageClassName` variable.



## Configuration variables for stateful set

These are our emphasized config options. For a full list, see the [values files](https://github.com/openworklabs/filecoin-chart/blob/master/values-spacerace.yaml).

| Parameter                          | Description                                                                                   | Default                                                                                       |
|------------------------------------|-----------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------|
| lotusStsCreate                     | Indicates if StatefulSet has to be created.                                                   | `true`                                                                                        |
| lotusStsLabels                     | Indicates the matching Pod Selector.                                                          | `app: lotus-node-app`<br/>`availability: public`<br/>`network: mainnet`<br/>`release: stable` |
| lotusStsReplicas                   | Indicates how many replicas should be in the StatefulSet.                                     | `1 `                                                                                          |
| nodeSelector                       | Contains all conditions that a node has to satisfy for the pod to be scheduled.               | `{}`                                                                                          |
| lotusVolume.name                   | Indicates name of Lotus volume.                                                               | `vol-lotus  `                                                                                 |
| lotusVolume.hostPath.path          | Indicates a local path to where the app Lotus is stored.                                      | `/nvme/disk`                                                                                  | 
| lotusVolume.hostPath.enabled       | If true, then `vol-lotus` is mounted by the to the path `/nvme/disk`.                         |`true`|
| InitContainerPermissions           | If true, then runs the init-container is created and directory `lotus/ snapshot/`.            | `true`                                                                            |
| downloadSnapshot.enabled           | If true, then downloads snapshot to zst format to the workingDir `/home/lotus_user/snapshot`. | `true`                                                                               |
| downloadSnapshot.unpack            | If true, then unpacks `snapshot.zst` and copying to the destination value `$SNAPSHOTURL`      | `true`                                                                                        |
| downloadSnapshot.checkLedger       | If true,  Ledger check the directory `/home/lotus_user/.lotus`.                               | `true `                                                                                             |
| downloadSnapshot.dependecies.aria2 | If $INFRA_CLEAR_RESTART = true, then Installing aria2.                                        | `1.36.0-r1`                                                                                            |
| downloadSnapshot.dependecies.zstd  | If $INFRA_CLEAR_RESTART = true, then Installing zstd.                                         | `1.5.5-r0`                                                                                    |
| lotusContainer.image               | Is a repository to pull lotus image from.                                                     | `glif/lotus:${IMAGE_TAG}`                                                                       |
| lotusContainer.imagePullPolicy     | Indicates when to pull the image.                                                             | `Always`                                                                                      |
| lotusContainer.command             | Runs the scripts.                                                                             |`["/etc/lotus/docker/run"]`|
| lotusContainer.preStopCommand      |                                                                                               |`["/bin/sh","-c","rm -f $INFRA_LOTUS_HOME/.lotus/sync-complete"]`|


## lotus env variables
| Parameter             | Description                                                                                                                                                                                                                                                                   | Default                                                                                       |
|-----------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------|
| INFRA_LOTUS_DAEMON    | Set it to TRUE to start the lotus daemon only.                                                                                                                                                                                                                                | `true`      |
| INFRA_LOTUS_HOME      | Defines where in the container’s filesystem the `.lotus` folder will be created.                                                                                                                                                                                              | `/home/lotus_user`                             |
| INFRA_CLEAR_RESTART   | Set it to TRUE to remove the lotus folder with chainstore and statestore. Useful when resetting the node. ! CAUTION THIS VALUE WILL DROP ALL THE CHAIN STATE ON THE START, PLEASE PUT IT TO TRUE IF YOU UNDERSTAND CONSEQUENCES.                                              | `false`                                                                          |
| INFRA_SYNC            | Set it to TRUE for the Lotus blockchain sync before the actual Lotus Daemon starts. Example of usage - Liveness probe in the k8s - you are waiting for the file $INFRA_LOTUS_HOME/.lotus/sync-complete and only after the file creation you add Lotus pod to the k8s service. | `true`                                                                                                                                                                                                                          |
| INFRA_SECRETVOLUME    | If TRUE, that the Kubernetes secret has been mounted to `/keystore` as a directory. That allows using the same authentication token despite the node being reset over and over again.                                                                                         |`true`|
| INFRA_PERSISTNODEID   | Set it to TRUE to copy the node ID from `/keystore/nodeid` to `$LOTUS_PATH/keystore/NRUWE4BSOAWWQ33TOQ`. This is needed for bootstrap node.                                                                                                                                   |`false`|
| INFRA_IMPORT_SNAPSHOT | If TRUE, then downloads snapshot from value $DOWNLOAD_FROM, unpacks  and copies to path from value $SNAPSHOTURL.                                                                                                                                                              | `true `                                                                                                                                                                                                                                                                         |
| DOWNLOAD_FROM         | Downloads snapshot from the path.                                                                                                                                                                                                                                             | "https://snapshots.mainnet.filops.net/minimal/latest.zst"<br/> "https://snapshots.calibrationnet.filops.net/minimal/latest.zst"                                                                                                                                               |
| SNAPSHOTURL           | Path in the container’s filesystem where copies unpacked snapshot                                                                                                                                                                                                             |`/home/lotus_user/snapshot/latest.car`|
| ALLOWED_DELAY         | The number 3 has been chosen because the epoch in Filecoin lasts 30 seconds; the average time to catch up a tipset is ~12 seconds.                                                                                                                                            | `3`                                                                                                                                                                                                                                                                            |


[//]: # ()
[//]: # (| `cache.enabled` | Enable cache service.                                                                                                                                                                    | `false` |)

[//]: # (| `cache.image` | Cache service image.                                                                                                                                                                     | `protofire/filecoin-rpc-proxy:0.0.1` |)

[//]: # (| `cache.nodeSelector.nodeLabel` | Run cache on node with nodeSelector                                                                                                                                                      | `role: worker` |)

[//]: # (| `IPFS.enabled` | Enable IPFS on the pod.                                                                                                                                                                  | `false` |)

[//]: # (| `ipfsDNS` | Overrides the IPFS endpoint when using services in separate pods                                                                                                                         | `` |)

[//]: # (| `image.repository` | Lotus Docker Image.                                                                                                                                                                      | `openworklabs/lotus` |)

[//]: # (| `ingress.annotations` | Defines annotations for general ingress                                                                                                                                                  | See values-{namespace}.yaml |)

[//]: # (| `ingress.enabled` | Enables ingress for this particular release                                                                                                                                              | `true` |)

[//]: # (| `ingress.host` | Defines DNS name that is used by NGINX to recognize valid requests                                                                                                                       | `node.glif.io` |)

[//]: # (| `ingress.lotus.gateway` | Enable ingress lotus-gateway                                                                                                                                                             | `false` |)

[//]: # (| `ingress.<service>.enabled` | Enables ingress for particular service.                                                                                                                                                  | `true` |)

[//]: # (| `ingress.<service>.annotations` | Defines annotations for particular service. Please read comments in `values.yaml` file to check the annotations that should be set to enable firewall-based access instead of JWT-based. | `<unset>` |)

[//]: # (| `healthcheck.enabled` | If you want to use custom lotus storage node healthcheck.                                                                                                                                | `<true>` |)

[//]: # (| `healthcheck.network` | Defines Filecoin network. Should be listed in [network specification repo]&#40;https://raw.githubusercontent.com/filecoin-project/network-info/master/static/networks&#41;                       | `mainnet` |)

[//]: # (| `lotusDNS` | Overrides the lotus endpoint when using services in separate pods                                                                                                                        | `` |)

[//]: # (| `Lotus.maxheapsize` | Enable and set [LOTUS_MAX_HEAP]&#40;https://docs.filecoin.io/get-started/lotus/configuration-and-advanced-usage/#environment-variables&#41; variable                                             | `false` |)

[//]: # (| `Lotus.service.gateway` | Enable lotus-gateway service                                                                                                                                                             | `false` |)

[//]: # (| `Lotus.service.release` | Defines master endpoint in lotusAPI schema                                                                                                                                               | `api-read` |)

[//]: # (| `replicaCount` | The number of Lotus replicas to run.                                                                                                                                                     | 1 |)

[//]: # (| `resources.<service>.requests.cpu` | The amount of vCPU &#40;per service&#41;.                                                                                                                                                        | `<unset>` |)

[//]: # (| `resources.<service>.requests.memory` | The amount of memory &#40;per service&#41;.                                                                                                                                                      | `<unset>` |)

[//]: # (| `resources.<service>.limit.cpu` | The ceiling amount of vCPU &#40;per service&#41;.                                                                                                                                                | `<unset>` |)

[//]: # (| `resources.<service>.limit.memory` | The ceiling amount of memory &#40;per service&#41;.                                                                                                                                              | `<unset>` |)

[//]: # (| `persistence.enabled` | Enable PVC instead of using hostPath.                                                                                                                                                    | `true` |)

[//]: # (| `persistence.hostPath` | Set the hostPath where data will be stored. Chart will store data of the each server in the dedicated subfolders under `hostPath` path.                                                  | `` |)

[//]: # (| `persistence.<service>.size` | Persistent volume storage size &#40;per service&#41;.                                                                                                                                            | `"200Gi"` |)

[//]: # (| `persistence.<service>.storageClassName` | Storage provisioner &#40;per service&#41;.                                                                                                                                                       | `gp2` |)

[//]: # (| `persistence.<service>.accessModes` | Persistent volume access mode &#40;per service&#41;.                                                                                                                                             | `"ReadWriteOnce"` |)

[//]: # (| `persistence.snapshots.*` | Described at [Snapshots]&#40;#snapshots&#41; section                                                                                                                                             |                                |)

[//]: # (| `podAntiAffinity.enabled` | Enable do not run lotus nodes on the same eks worker&#40;instance&#41;                                                                                                                           | `false` |)

[//]: # (| `secretVolume.enabled` | If you want to reuse token across installations. See [here]&#40;#Lotus-JWT&#41; for more details.                                                                                                | `false` |)

[//]: # (| `secretVolume.persistNodeID` | If you want to persist nodeID - append the `nodeid` key to the secret created for the [JWT token]&#40;#Lotus-JWT&#41;. Used only if secretVolume is enabled.                                     | `false` |)

[//]: # (| `serviceAccount.create` | Create service account. Must be enabled when enabling snapshot automation.                                                                                                               | `true` |)

[//]: # (| `serviceAccount.name` | Must be set when `serviceAccount.create` is `true`. Will be prefixed with release name.                                                                                                  | `acc` |)

## Snapshots

[//]: # (To start building Snapshots your persistent volume usually should be created using special CSI-compatible class. In most cases you can migrate your existing workloads, so please refer to the driver documentation for more details.)

[//]: # ()
[//]: # (We are supporting [AWS EBS CSI driver]&#40;https://github.com/kubernetes-sigs/aws-ebs-csi-driver&#41; out of the box. To create persistent volumes make sure you have the `ebs-sc` storage class installed. To perform installation go to the [examples folder]&#40;https://github.com/kubernetes-sigs/aws-ebs-csi-driver/tree/master/examples/kubernetes/snapshot&#41; and complete the first step of instruction. After then set `persistence.snapshots.enabled` to `true` so the Charts will automatically create volumes of  the `ebs-sc` class. To override this behavior one can set `persistence.<service>.storageClassName` for each of the services. In this case Charts will create PV of the specified custom class.)

[//]: # ()
[//]: # (To automate snapshot operations operator can set `persistence.snapshots.automation` parameters. If `creation` is set to `true` Charts will deploy a Cron job that will create snapshots on a daily basis.  If `deletion` is set to `true`  Charts will deploy a Cron job that will delete a snapshots for specific release if the number of snapshots is more than `retain.count`.)

[//]: # ()
[//]: # (In case you want to create the new release based on existing snapshot one can set `persistence.snapshots.automation.restore.enabled` to `true`. In that case Lotus PV will be created based on snapshot named `persistence.snapshots.automation.restore.name`. Note that Snapshot should exist in the very same namespace where the release is deployed.)

### Internal snapshots and IPFS system

[//]: # (One can setup `persistence.snapshots.uploadToIpfs.enabled` to `true` to make an automated cronjob that will take chain snapshots on a daily basis and sharing them through IPFS. There are two ways of making snapshots: hot and cold. Hot takes a while but does not require Lotus node to stop. Cold is way more fast, but implies some downwtime.)

[//]: # ()
[//]: # (To setup hot snapshotting system set `persistence.snapshots.uploadToIpfs.export` to `hot`. It will use `lotus chain export` command, and import the exported `.car` file into IPFS system. Note that IPFS must be running for snapshotting system to take any effect.)

[//]: # (To setup cold snapshotting system set `persistence.snapshots.uploadToIpfs.export` to `cold`. It will use `lotus-shed export` command. When using cold snapshotting it is important to set both `.Values.persistence.snapshots.uploadToIpfs.shedPeriod` and `.Values.persistence.snapshots.uploadToIpfs.cron` variables. First defines the period of `lotus-shed export` command execution in period format &#40;1s, 1m, 1h, 1d&#41;, second defines a snapshot file sharing update period in cron format &#40;X X X X X&#41;.)

[//]: # ()
[//]: # (Also `persistence.snapshots.uploadToIpfs.shareToGist` can be configured to automatically refresh the IPFS hash of the exported `.car` at the GitHub Gist. Note that the job will need an access to this Gist. To provide the job with the credentials use secret described in the [persistent secrets]&#40;#persistent-secret&#41; section and add `ssh` key to Kubernetes Secret with base64-encoded private key content.)

[//]: # ()
[//]: # (Note: You must use SSH URL in `persistence.snapshots.uploadToIpfs.shareToGist.address` so the `git push` command used inside of the job could use the provided ssh key to access the Gist.)

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

## Deployment options

Generally - there are two way of deploying Lotus node with dependent services:
    1 - deployed in the single pod (single helm chart). Thus way each container will communicate through loopback interface
    2 - deployed in the separate pods (multiple helm charts). In that case you will need to set `lotusDNS` when deploying IPFS, StateDiff and `ipfsDNS` when deploying Lotus

  *NOTE*: Internal snapshotting are currently available for the single pod deployment option only!
