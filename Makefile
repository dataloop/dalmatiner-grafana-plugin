VERSION=2.5.0
PLUGIN_DIR=~/dalmatiner-grafana-plugin
COMPONENT=fifo-grafana
BUILD_ROOT=/tmp
export GOPATH=$(BUILD_ROOT)/GO
ROOT=$(GOPATH)/src/github.com/grafana/grafana

all: export GOPATH=$(BUILD_ROOT)/GO
all: package

deps:
	pkgin -y in go git-base build-essential nodejs

download:
	-rm -r $(ROOT)
	go get github.com/grafana/grafana
	cd $(ROOT); git fetch; git checkout v$(VERSION)

backend:
	cd $(ROOT) && \
		go run build.go setup && \
		$(GOPATH)/bin/godep restore && \
		go build .
		
frontend:
	cd $(ROOT) && \
		npm install --force && \
		(test -e public/app/plugins/datasource/dalmatinerdb || ln -s $(PLUGIN_DIR)/dalmatinerdb public/app/plugins/datasource/dalmatinerdb) && \
		node_modules/grunt-cli/bin/grunt build build-post-process --force

package: deps download backend frontend
	mkdir -p $(ROOT)/tmp/bin
	cp $(ROOT)/grafana $(ROOT)/tmp/bin/
	cp custom.ini $(ROOT)/tmp/conf/custom.ini.example
	cp manifest.xml $(ROOT)/tmp/
	make -C rel/pkg package VERSION=$(VERSION) ROOT=$(ROOT)/tmp
