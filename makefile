
build/image: src Dockerfile rsyslog.conf guard.sh e2guardian.conf build/ca.crt build/ca.key build/cert.key
	test -d $(@D) || mkdir -p $(@D)
	docker build --force-rm -t guard .
	test -z "`docker images -q -f dangling=true`" || docker rmi `docker images -q -f dangling=true`
	touch build/image

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

