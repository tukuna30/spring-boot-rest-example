include env_make
NS = blog
VERSION ?= latest

REPO = sbdemo
NAME = demo
INSTANCE = default

.PHONY: build push shell run start stop rm release

builder:
	docker build -t builder:mvn -f Dockerfile.build .

maven: builder
	docker run -it --rm -v $(shell pwd):/usr/src/app -v $(HOME)/.m2:/root/.m2 --workdir /usr/src/app builder:mvn mvn package -Dwar.output.dir=dist -Dmaven.test.skip=true

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