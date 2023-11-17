MAKE_REL_PATH:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

GOLANG ?= go
GOARCH ?= arm64
GO_BUILD_FLAGS ?= -ldflags="-s -w"
GO_LAMBDA_TAGS ?= -tags "lambda.norpc"
GO_BUILD ?= CGO_ENABLED=0 GOOS=linux GOARCH=${GOARCH} ${GOLANG} build ${GO_BUILD_FLAGS}
GO_BUILD_FILES := $(shell find . -type f -not -path "./.git/*" -not -path "./bin/*" -not -name "*_test.go")

bin/%/bootstrap: ${GO_BUILD_FILES}
	cd cmd/$(patsubst bin/%/bootstrap,%,$@) && ${GO_BUILD} ${GO_LAMBDA_TAGS} -o ${MAKE_REL_PATH}/$@

.PHONY: build
build: bin/logme/bootstrap
