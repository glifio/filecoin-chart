all: lint package
<<<<<<< HEAD
NODE = space06
=======
NODE = space02-dev
>>>>>>> origin/dev
NAMESPACE = spacerace
## lotus nodes management
nodedelete:
	helm -n spacerace delete $(NODE)
	kubectl -n $(NAMESPACE) delete pvc vol-lotus-$(NODE)-lotus-0

nodereinit:
	helm -n spacerace delete $(NODE)
<<<<<<< HEAD
	helm upgrade --install -f values-spacerace.yaml -f values/prod/$(NAMESPACE)/$(NODE).yaml $(NODE) -n $(NAMESPACE) .
=======
	helm upgrade --install -f values-spacerace.yaml -f values/dev/spacerace/$(NODE).yaml $(NODE) -n $(NAMESPACE) .
>>>>>>> origin/dev

nodereinstall:
	helm -n spacerace delete $(NODE)
	kubectl -n $(NAMESPACE) delete pvc vol-lotus-$(NODE)-lotus-0
<<<<<<< HEAD
	helm upgrade --install -f values-spacerace.yaml -f values/prod/$(NAMESPACE)/$(NODE).yaml $(NODE) -n $(NAMESPACE) .

nodeinstall:
	helm upgrade --install -f values-spacerace.yaml -f values/prod/$(NAMESPACE)/$(NODE).yaml $(NODE) -n $(NAMESPACE) .

nodedry:
	helm upgrade --install -f values-spacerace.yaml -f values/prod/$(NAMESPACE)/$(NODE).yaml $(NODE) -n $(NAMESPACE) --dry-run .
=======
	helm upgrade --install -f values-spacerace.yaml -f values/dev/spacerace/$(NODE).yaml $(NODE) -n $(NAMESPACE) .

nodeinstall:
	helm upgrade --install -f values-spacerace.yaml -f values/dev/spacerace/$(NODE).yaml $(NODE) -n $(NAMESPACE) .

nodedry:
	helm upgrade --install -f values-spacerace.yaml -f values/dev/spacerace/$(NODE).yaml $(NODE) -n $(NAMESPACE) --dry-run .
>>>>>>> origin/dev

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
<<<<<<< HEAD
	kubectl create secret generic lotus-secret --from-file=token=token3 --from-file=privatekey=MF2XI2BNNJ3XILLQOJUXMYLUMU3
=======
	kubectl create secret generic lotus-secret --from-file=token=token3 --from-file=privatekey=MF2XI2BNNJ3XILLQOJUXMYLUMU3
>>>>>>> origin/dev
