
SERVER_SOURCE=./cmd/server
CLIENT_SOURCE=./cmd/shell
LDFLAGS="-X main.targetDomain=$(DOMAIN_NAME) -X main.encryptionKey=$(ENCRYPTION_KEY) -s -w"
GCFLAGS="all=-trimpath=$GOPATH"

CLIENT_BINARY=chashell
SERVER_BINARY=chaserv
TAGS=release

OSARCH = "linux/amd64 linux/386 linux/arm windows/amd64 windows/386 darwin/amd64 darwin/arm64"

.DEFAULT: help

help: ## Show Help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

check-env: ## Check if necessary environment variables are set.
ifndef DOMAIN_NAME
	$(error DOMAIN_NAME is undefined)
endif
ifndef ENCRYPTION_KEY
	$(error ENCRYPTION_KEY is undefined)
endif

build: check-env ## Build for the current architecture.
	go build -ldflags $(LDFLAGS) -gcflags $(GCFLAGS) -tags $(TAGS) -o release/$(CLIENT_BINARY) $(CLIENT_SOURCE) && \
	go build -ldflags $(LDFLAGS) -gcflags $(GCFLAGS) -tags $(TAGS) -o release/$(SERVER_BINARY) $(SERVER_SOURCE)

dep: check-env ## Get all the required dependencies
	go install github.com/mitchellh/gox

build-client: check-env ## Build the chashell client.
	@echo "Building shell"
	gox -osarch=$(OSARCH) -ldflags=$(LDFLAGS) -gcflags=$(GCFLAGS) -tags $(TAGS) -output "release/chashell_{{.OS}}_{{.Arch}}" ./cmd/shell

build-server: check-env ## Build the chashell server.
	@echo "Building server"
	gox -osarch=$(OSARCH) -ldflags=$(LDFLAGS) -gcflags=$(GCFLAGS) -tags $(TAGS) -output "release/chaserv_{{.OS}}_{{.Arch}}" ./cmd/server


build-all: check-env build-client build-server ## Build everything.

proto: ## Build the protocol buffer file
	protoc -I=proto/ --go_out=lib/protocol chacomm.proto

clean: ## Remove all the generated binaries
	rm -f release/chaserv*
	rm -f release/chashell*
