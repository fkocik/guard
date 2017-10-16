
build/image: src Dockerfile rsyslog.conf guard.sh e2guardian.conf
	test -d $(@D) || mkdir -p $(@D)
	docker build --force-rm -t guard .
	test -z "`docker images -q -f dangling=true`" || docker rmi `docker images -q -f dangling=true`
	touch build/image

src:
	git submodule update --init

clean:
	rm -rf build
	test -z "`docker images -q guard`" || docker rmi guard
	test -z "`docker images -q -f dangling=true`" || docker rmi `docker images -q -f dangling=true`

