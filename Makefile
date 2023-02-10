.PHONY: build build-alpine clean test help default

BIN_NAME=wangjiaxin/ubuntu20.04-cuda11.3.0-py37-torch1.11.0-tf1.15.5
BIN_NAME_ALIAS=registry.cn-beijing.aliyuncs.com/showmethemoney/damobase
GIT_TAG := $(shell git describe --abbrev=0 --tags 2>/dev/null || echo 0.0.0)
GIT_COMMIT_SEQ := $(shell git rev-parse --short HEAD)
GIT_COMMIT_CNT := $(shell git rev-list --all --count)
VERSION := $(GIT_TAG)-$(GIT_COMMIT_CNT)-$(GIT_COMMIT_SEQ)
FULL_VERSION := $(BIN_NAME):$(VERSION)
FULL_VERSION_ALIAS := $(BIN_NAME_ALIAS):$(VERSION)

default: test

help:
	@echo 'Management commands for money-common:'
	@echo
	@echo 'Usage:'
	@echo '    make build           Compile the project.'
	@echo '    make clean           Clean the directory tree.'
	@echo

build:
	@echo "building ${BIN_NAME} ${VERSION}"
	@echo "GOPATH=${GOPATH}"
	go build -o bin/${BIN_NAME}

docker-save:
	docker save $(FULL_VERSION) > $(VERSION).tar

docker-build:
	docker build . -t $(FULL_VERSION) && docker tag $(FULL_VERSION) $(BIN_NAME):latest && docker tag $(FULL_VERSION) $(BIN_NAME_ALIAS):latest && docker tag $(FULL_VERSION) $(BIN_NAME_ALIAS):$(VERSION)

docker-push:
	docker push $(FULL_VERSION_ALIAS) && docker push $(FULL_VERSION_ALIAS):latest

docker-pull:
	docker pull $(FULL_VERSION_ALIAS) && docker push $(FULL_VERSION_ALIAS):latest

docker-test:
	docker run --rmit $(FULL_VERSION_ALIAS) bash

docker: docker-build docker-save docker-push

clean:
	@test ! -e bin/${BIN_NAME} || rm bin/${BIN_NAME}

test:
	go test ./...
