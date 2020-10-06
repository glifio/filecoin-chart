all: lint package
NODE = space03-dev
ENV = dev
NAMESPACE = spacerace
## lotus nodes management
nodedelete:
	helm -n $(NAMESPACE) delete $(NODE)
	kubectl -n $(NAMESPACE) delete pvc vol-lotus-$(NODE)-lotus-0

nodereinit:
	helm -n spacerace delete $(NODE)
	helm upgrade --install -f values-spacerace.yaml -f values/$(ENV)/$(NAMESPACE)/$(NODE).yaml $(NODE) -n $(NAMESPACE) .

nodereinstall:
	helm -n spacerace delete $(NODE)
	kubectl -n $(NAMESPACE) delete pvc vol-lotus-$(NODE)-lotus-0
	helm upgrade --install -f values-spacerace.yaml -f values/$(ENV)/$(NAMESPACE)/$(NODE).yaml $(NODE) -n $(NAMESPACE) .

nodeinstall:
	helm upgrade --install -f values-spacerace.yaml -f values/$(ENV)/$(NAMESPACE)/$(NODE).yaml $(NODE) -n $(NAMESPACE) .

nodedry:
	helm upgrade --install -f values-spacerace.yaml -f values/$(ENV)/$(NAMESPACE)/$(NODE).yaml $(NODE) -n $(NAMESPACE) --dry-run .

cascadests:
	kubectl -n $(NAMESPACE) delete sts $(NODE)-lotus --cascade false

## command to change snapshot in statefulset
## change persistence.snapshots.name before runing
stschange: cascadests nodeinstall

lint:
	helm lint .

package:
	helm package .
## minikube options

minikube-upgrade:
	helm upgrade --install -f values.yaml -f values-minikube.yaml filecoin .

minikube-dry-run:
	helm upgrade --install --dry-run --debug -f values.yaml -f values-minikube.yaml filecoin .

## admin configuration
create-secret:
	kubectl create secret generic lotus-secret --from-file=token=token3 --from-file=privatekey=MF2XI2BNNJ3XILLQOJUXMYLUMU3
