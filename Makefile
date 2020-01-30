all: lint package

install:
	helm install filecoin .

upgrade:
	helm upgrade --install filecoin . 

uninstall:
	helm uninstall filecoin

lint:
	helm lint .

package:
	helm package .

dry-run:
	helm upgrade --install --dry-run --debug filecoin .

port-forward-service:
	kubectl port-forward service/lotus-node-service 1234:1234

port-forward-app:
	kubectl port-forward pod/lotus-node-app-0 1234:1234

## debug
log-nginx:
	kubectl logs -n ingress-nginx -f nginx-ingress-controller-948ffd8cc-6g57p

conf-nginx:
	kubectl exec -it -n ingress-nginx nginx-ingress-controller-948ffd8cc-6g57p cat /etc/nginx/nginx.conf