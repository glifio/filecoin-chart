all: lint package

install:
	helm install filecoin .

uninstall:
	helm uninstall filecoin

lint:
	helm lint .

package:
	helm package .

dry-run:
	helm install --dry-run --debug filecoin .

port-forward-service:
	kubectl port-forward service/lotus-node-service 1234:1234

port-forward-app:
	kubectl port-forward pod/lotus-node-app-0 1234:1234