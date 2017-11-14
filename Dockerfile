FROM vbatts/slackware
MAINTAINER Fabien KOCIK <fabien@knf.dyndns.org>
RUN slackpkg update
RUN echo y | slackpkg install vim python git automake autoconf make gcc pcre openssl cyrus-sasl ca-certificates perl m4 libtool pkg-config glibc libmpc binutils kernel-headers guile gc libffi flex zlib bison ed glibc-zoneinfo
RUN localedef -i fr_FR -f UTF-8 fr_FR.utf8
ENV LANG=fr_FR.utf8
RUN ln -fs /usr/share/zoneinfo/Europe/Paris /etc/localtime

ADD libestr /usr/src/libestr
ADD libfastjson /usr/src/libfastjson
ADD liblogging /usr/src/liblogging
ADD rsyslog /usr/src/rsyslog
ADD e2guardian /usr/src/e2guardian
ADD Squid /usr/src/Squid

WORKDIR /usr/src/libestr
RUN ./autogen.sh --libdir=/usr/lib64 && make && make install

WORKDIR /usr/src/libfastjson
RUN ./autogen.sh --libdir=/usr/lib64 && make && make install

WORKDIR /usr/src/liblogging
RUN ./autogen.sh --libdir=/usr/lib64 --disable-man-pages && make && make install

WORKDIR /usr/src/rsyslog
RUN 	./autogen.sh --enable-libgcrypt=no --libdir=/usr/lib64 && \
	make && make install && \
	mkdir -p /var/spool/rsyslog && \
	rm -f /etc/rsyslog.conf
ADD rsyslog.conf /etc/

WORKDIR /usr/src/Squid
RUN 	./bootstrap.sh && \
	./configure --libdir=/usr/lib64 --prefix=/usr --sysconfdir=/etc --localstatedir=/var --with-logdir=/var/log/squid && \
	make && make install && \
	chown nobody.nobody /var/log/squid

WORKDIR /usr/src/e2guardian
RUN 	./autogen.sh && \
	./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --libdir=/usr/lib64 --enable-sslmitm=yes && \
	make && make install && \
	chown nobody.nobody /var/log/e2guardian

ADD knfinit /usr/src/knfinit
RUN make -C /usr/src/knfinit all && install -m 0755 /usr/src/knfinit/knfinit /usr/local/bin

WORKDIR /etc/e2guardian

RUN mkdir -p certs/generatedcerts && chown nobody.nobody certs/generatedcerts
ADD build/ca.crt /etc/e2guardian/certs/
ADD build/ca.key /etc/e2guardian/certs/
ADD build/cert.key /etc/e2guardian/certs/
ADD http://dsi.ut-capitole.fr/blacklists/download/blacklists.tar.gz /etc/e2guardian/lists/
RUN cd lists && tar zxvf blacklists.tar.gz && rm -f blacklists.tar.gz
ADD configure.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/configure.sh
RUN configure.sh | sort
RUN find /usr/share/e2guardian/languages -type f -name 'template.html' -exec sed -i 's/YOUR ORG NAME/KNF Guard/' {} \;

VOLUME /var/log

EXPOSE 8080
ADD guard.sh logger.sh squid.sh e2guardian.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/*.sh
ENTRYPOINT [ "/bin/bash" ]
ARG BUILD_GUARD_VERSION
ENV GUARD_VERSION $BUILD_GUARD_VERSION
CMD [ "/usr/local/bin/guard.sh" ]

RUN echo "cache_mgr fabien@knf.dyndns.org" >> /etc/squid.conf
RUN rm -f e2guardian.conf e2guardianf1.conf
ADD e2*.conf /etc/e2guardian/
ADD whitelist /usr/src/
RUN 	cp /etc/e2guardian/lists/exceptionsitelist /usr/src/exceptionsitelist.ref && \
	cat /usr/src/whitelist >> /etc/e2guardian/lists/exceptionsitelist

