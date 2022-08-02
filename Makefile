all: lint package

## Edit node and env
#
## Deploy archive_node
#NODE = calibrationapi-archive
#ENV = dev
#NAMESPACE = network

## Deploy api_read_node
#NODE = api-read-dev
#ENV = dev
#NAMESPACE = network

##deploy cache service for api-read
#NODE = api-read-cache-dev
#ENV = dev
#NAMESPACE = network

## Deploy calibnetapi
#NODE = calibrationapi
#ENV = dev
#NAMESPACE = network

## Deploy calibnetapi-jwt
#NODE = calibrationapi-jwt
#ENV = dev
#NAMESPACE = network

## lotus nodes management


###deploy cache service for api-read mainnet
#NODE = api-read-cache
#ENV = mainnet
#NAMESPACE = network

# Deploy api_read_node
NODE = api-read-master
ENV = mainnet
NAMESPACE = network

nodeInstall:
	helm upgrade --history-max 3 --install -f values.yaml -f values/$(ENV)/$(NAMESPACE)/$(NODE).yaml $(NODE) -n $(NAMESPACE) .

nodeReinit:
	helm -n $(NAMESPACE) delete $(NODE)
	helm upgrade --history-max 3 --install -f values.yaml -f values/$(ENV)/$(NAMESPACE)/$(NODE).yaml $(NODE) -n $(NAMESPACE) .

nodeDelete:
	helm -n $(NAMESPACE) delete $(NODE)
	helm delete --install -f values.yaml -f values/$(ENV)/$(NAMESPACE)/$(NODE).yaml $(NODE) -n $(NAMESPACE) .

# nodeReinstall:
# 	helm -n $(NAMESPACE) delete $(NODE)
# 	kubectl -n $(NAMESPACE) delete pvc vol-lotus-$(NODE)-lotus-0
# 	helm upgrade --history-max 3 --install -f values.yaml -f values/$(ENV)/$(NAMESPACE)/$(NODE).yaml $(NODE) -n $(NAMESPACE) .

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
