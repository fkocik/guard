FROM vbatts/slackware
MAINTAINER Fabien KOCIK <fabien@knf.dyndns.org>
RUN slackpkg update
RUN echo y | slackpkg install vim python git automake autoconf make gcc pcre openssl cyrus-sasl ca-certificates perl m4 libtool pkg-config glibc libmpc binutils kernel-headers guile gc libffi flex zlib bison ed
ENV LANG=fr_FR.UTF-8

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
	./configure --libdir=/usr/lib64 --prefix=/usr --sysconfdir=/etc --localstatedir=/var && \
	make && make install && \
	chown nobody.nobody /var/logs

WORKDIR /usr/src/e2guardian
RUN 	./autogen.sh && \
	./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --libdir=/usr/lib64 --enable-sslmitm=yes && \
	make && make install

WORKDIR /etc/e2guardian

RUN mkdir -p certs/generatedcerts
ADD build/ca.crt /etc/e2guardian/certs/
ADD build/ca.key /etc/e2guardian/certs/
ADD build/cert.key /etc/e2guardian/certs/
ADD http://dsi.ut-capitole.fr/blacklists/download/blacklists.tar.gz /etc/e2guardian/lists/
RUN cd lists && tar zxvf blacklists.tar.gz && rm -f blacklists.tar.gz

EXPOSE 8080
ADD guard.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/guard.sh
ENTRYPOINT [ "/bin/bash" ]
CMD [ "/usr/local/bin/guard.sh" ]

RUN rm -f e2guardian.conf e2guardianf1.conf
ADD e2*.conf /etc/e2guardian/


