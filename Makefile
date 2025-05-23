all: lint package

# DEV environment

### Deploy api_read_node
NODE = space07
ENV = mainnet
NAMESPACE = network

##deploy cache service for api-read
#NODE = api-read-cache-dev
#ENV = dev
#NAMESPACE = network


## lotus nodes management

# Calibration nodes

# Deploy calibrationapi
# NODE = calibrationapi-1
# ENV = mainnet
# NAMESPACE = network

# # Deploy calibrationapi-archive-node
# NODE = calibrationapi-archive-node
# ENV = mainnet
# NAMESPACE = network


####deploy cache service for api-read v0 mainnet
#NODE = api-read-v0-cache
#ENV = mainnet
#NAMESPACE = network

### Deploy api_read_master_node
# NODE = api-read-master
# ENV = mainnet
# NAMESPACE = network

### Deploy api_read_slave_0_node
# NODE = api-read-slave-0
# ENV = mainnet
# NAMESPACE = network

### Deploy api_read_slave_1_node
#NODE = api-read-slave-1
#ENV = mainnet
#NAMESPACE = network

### Deploy api_read_slave_2_node
# NODE = api-read-slave-10
# ENV = mainnet
# NAMESPACE = network

### Deploy api_read_slave_3_node
# NODE = api-read-slave-3
# ENV = mainnet
# NAMESPACE = network

# #### Deploy space00
# NODE = space00
# ENV = mainnet
# NAMESPACE = network

### Deploy space06
# NODE = space06
# ENV = mainnet
# NAMESPACE = network

### Deploy space06-cache
#NODE = space06-cache
#ENV = mainnet
#NAMESPACE = network

#### Deploy space06-1
# NODE = calibrationapi-archive-node
# ENV = mainnet
# NAMESPACE = network

#### Deploy space07
# NODE = space00
# ENV = mainnet
# NAMESPACE = network

#### Deploy space07-cache
#NODE = space07-cache
#ENV = mainnet
#NAMESPACE = network

### Deploy blockscout-0
# NODE = blockscout-0
# ENV = mainnet
# NAMESPACE = network


### Deploy coinfirm
# NODE = coinfirm
# ENV = mainnet
# NAMESPACE = network


### Deploy fvm-archive
# NODE = fvm-archive
# ENV = mainnet
# NAMESPACE = network

# OVH environment

### Deploy spacenet
# NODE = spacenet-public
# ENV = mainnet
# NAMESPACE = network

#### Deploy spacenet-slave
# NODE = spacenet-public-slave-0
# ENV = mainnet
# NAMESPACE = network


nodeInstall:
	helm upgrade --history-max 3 --install -f values.yaml -f values/$(ENV)/$(NAMESPACE)/$(NODE).yaml $(NODE) -n $(NAMESPACE) .

nodeReinit:
	helm -n $(NAMESPACE) delete $(NODE)
	helm upgrade --history-max 3 --install -f values.yaml -f values/$(ENV)/$(NAMESPACE)/$(NODE).yaml $(NODE) -n $(NAMESPACE) .

nodeDelete:
	helm -n $(NAMESPACE) delete $(NODE)

diff:
	helm diff upgrade --install -f values.yaml -f values/$(ENV)/$(NAMESPACE)/$(NODE).yaml $(NODE) -n $(NAMESPACE) .

nodeDeleteFull:
	helm -n $(NAMESPACE) delete $(NODE)
	kubectl -n $(NAMESPACE) delete pvc vol-lotus-$(NODE)-lotus-0

nodeDeleteSpot:
	helm -n $(NAMESPACE) delete $(NODE)

cascadests:
	kubectl -n $(NAMESPACE) delete sts $(NODE)-lotus --cascade=false

## command to change snapshot in statefulset
## change persistence.snapshots.name before runing
stschange: cascadests nodeinstall

lint:
	helm lint .

package:
	helm package .

## admin configuration
create-secret:
	kubectl create secret generic lotus-secret --from-file=token=token3 --from-file=privatekey=MF2XI2BNNJ3XILLQOJUXMYLUMU3
