all: lint package
NODE = space07

## lotus nodes management
nodedelete:
	helm -n spacerace delete $(NODE)
	kubectl -n spacerace delete pvc vol-lotus-$(NODE)-lotus-0
nodeinstall:
	helm upgrade --install -f values-spacerace.yaml -f values/prod/spacerace/$(NODE).yaml $(NODE) -n spacerace .
nodedry:
	helm upgrade --install -f values-spacerace.yaml -f values/prod/spacerace/$(NODE).yaml $(NODE) -n spacerace --dry-run .

lint:
	helm lint .

package:
	helm package .
## minikube options

minikube-upgrade:
	helm upgrade --install -f values.yaml -f values-minikube.yaml filecoin .

minikube-dry-run:
	helm upgrade --install --dry-run --debug -f values.yaml -f values-minikube.yaml filecoin .

port-forward-service:
	kubectl port-forward service/lotus-node-service 1234:1234

port-forward-app:
	kubectl port-forward pod/lotus-node-app-0 1234:1234

## admin configuration
create-secret:
	kubectl create secret generic lotus-secret --from-file=token=token3 --from-file=privatekey=MF2XI2BNNJ3XILLQOJUXMYLUMU3

## debug
log-nginx:
	kubectl logs -n ingress-nginx -f nginx-ingress-controller-948ffd8cc-6g57p

conf-nginx:
	kubectl exec -it -n ingress-nginx nginx-ingress-controller-948ffd8cc-6g57p cat /etc/nginx/nginx.conf
