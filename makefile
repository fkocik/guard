DIRTY=$(shell test -z "`git status -s`" && echo "" || echo ".dirty")
REVISION=$(shell git rev-parse --short HEAD)$(DIRTY)
REG=registry:5000

all:
	@$(MAKE) BRANCH=`git status -s -b | sed -r -n 's/^##\s+([^\.]+)\.{3}.*$$/\1/p'` _all

_all: build/image
	@test -z "`docker images -q -f dangling=true`" || docker rmi `docker images -q -f dangling=true`
ifeq ($(DIRTY),.dirty)
	@echo "Dirty $(BRANCH) branch: no push"
else
ifeq ($(BRANCH),master)
	docker tag guard $(REG)/guard:$(REVISION)
	docker tag guard $(REG)/guard
	docker push $(REG)/guard:$(REVISION)
	docker push $(REG)/guard
	docker rmi $(REG)/guard:$(REVISION)
else
	@echo "On unstable $(BRANCH) branch: no push"
endif
endif

build/image: src Dockerfile rsyslog.conf guard.sh e2guardian.conf build/ca.crt build/ca.key build/cert.key
	test -d $(@D) || mkdir -p $(@D)
	docker build --force-rm -t guard .
	touch $@

build/ca.crt: build/ca.key ca.conf
	openssl req -new -x509 -days 7300 -extensions v3_ca -key $< -out $@ -config ca.conf

build/%.key:
	test -d $(@D) || mkdir -p $(@D)
	openssl genrsa -out $@ 2048

src:
	git submodule update --init

clean:
	rm -rf build
	test -z "`docker images -q guard`" || docker rmi guard
	test -z "`docker images -q -f dangling=true`" || docker rmi `docker images -q -f dangling=true`

