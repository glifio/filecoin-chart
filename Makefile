all: lint package

install:
	helm upgrade --install filecoin .

upgrade:
	helm upgrade --install filecoin . 

minikube-upgrade:
	helm upgrade --install -f values.yaml -f values-minikube.yaml filecoin . 

interop-aws-upgrade:
	helm upgrade --install --namespace interopnet -f values.yaml -f values-interopnet-aws.yaml node01 .
	helm upgrade --install --namespace interopnet -f values.yaml -f values-interopnet-aws.yaml node02 .
	helm upgrade --install --namespace interopnet -f values.yaml -f values-interopnet-aws.yaml node03 .
	helm upgrade --install --namespace interopnet -f values.yaml -f values-interopnet-aws.yaml node04 .
	helm upgrade --install --namespace interopnet -f values.yaml -f values-interopnet-aws.yaml node05 .
	helm upgrade --install --namespace interopnet -f values.yaml -f values-interopnet-aws.yaml node06 .
	helm upgrade --install --namespace interopnet -f values.yaml -f values-interopnet-aws.yaml node07 .

aws-delete-pods:
	kubectl -n interopnet delete po node01-lotus-0
	kubectl -n interopnet delete po node02-lotus-0
	kubectl -n interopnet delete po node03-lotus-0
	kubectl -n interopnet delete po node04-lotus-0
	kubectl -n interopnet delete po node05-lotus-0
	kubectl -n interopnet delete po node06-lotus-0
	kubectl -n interopnet delete po node07-lotus-0

interop-aws-reset:
	kubectl -n interopnet delete sts $(NODE)-lotus
	kubectl -n interopnet delete pvc vol-$(NODE)-lotus-0
	helm upgrade --install --namespace interopnet -f values.yaml -f values-interopnet-aws.yaml $(NODE) .

interop-aws-install:
	helm upgrade --install --dry-run --namespace interopnet -f values.yaml -f values-interopnet-aws.yaml $(NODE) .

uninstall:
	helm uninstall filecoin

lint:
	helm lint .

package:
	helm package .

dry-run:
	helm upgrade --install --dry-run --debug filecoin .

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

