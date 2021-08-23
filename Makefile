all: lint package

## Edit node and env
NODE = api-read-dev
ENV = dev
NAMESPACE = spacerace

## lotus nodes management

nodeInstall:
	helm upgrade --install -f values-$(NAMESPACE).yaml -f values/$(ENV)/$(NAMESPACE)/$(NODE).yaml $(NODE) -n $(NAMESPACE) .

nodeReinit:
	helm -n $(NAMESPACE) delete $(NODE)
	helm upgrade --install -f values-$(NAMESPACE).yaml -f values/$(ENV)/$(NAMESPACE)/$(NODE).yaml $(NODE) -n $(NAMESPACE) .

nodeReinstall:
	helm -n $(NAMESPACE) delete $(NODE)
	kubectl -n $(NAMESPACE) delete pvc vol-lotus-$(NODE)-lotus-0
	helm upgrade --install -f values-$(NAMESPACE).yaml -f values/$(ENV)/$(NAMESPACE)/$(NODE).yaml $(NODE) -n $(NAMESPACE) .

diff:
	helm diff upgrade --install -f values-$(NAMESPACE).yaml -f values/$(ENV)/$(NAMESPACE)/$(NODE).yaml $(NODE) -n $(NAMESPACE) .

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
