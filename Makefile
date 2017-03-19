include env_make
NS = blog
VERSION ?= latest

REPO = sbdemo
NAME = demo
INSTANCE = default

.PHONY: builder mvn-package mvn-test docker build push shell run start stop rm release

builder:
	docker build -t builder:mvn -f Dockerfile.build .

mvn-package: builder
	docker run -it --rm -v $(shell pwd)/target:/usr/src/app/target builder:mvn package -T 1C -o -Dmaven.test.skip=true

mvn-test: builder
	docker run -it --rm -v $(shell pwd)/target:/usr/src/app/target builder:mvn -T 1C -o test

docker: 
	docker build -t $(NS)/$(REPO):$(VERSION) dist

build: maven
	make docker

push:
	docker push $(NS)/$(REPO):$(VERSION)

shell:
	docker run --rm --name $(NAME)-$(INSTANCE) -i -t $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(REPO):$(VERSION) /bin/sh

run:
	docker run --rm --name $(NAME)-$(INSTANCE) $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(REPO):$(VERSION)

start:
	docker run -d --name $(NAME)-$(INSTANCE) $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(REPO):$(VERSION)

stop:
	docker stop $(NAME)-$(INSTANCE)

rm:
	docker rm $(NAME)-$(INSTANCE)

log:
	docker logs $(NAME)-$(INSTANCE)

release: build
	make push -e VERSION=$(VERSION)

default: build