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
