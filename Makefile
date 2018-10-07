VERSION=1.31.1
IMAGE=mediawiki

PROJECT=smartbrood

.PHONY: build push all

build:
	docker build -t $(PROJECT)/$(IMAGE):$(VERSION) .

push:
	docker push $(PROJECT)/$(IMAGE):$(VERSION)

all: build

