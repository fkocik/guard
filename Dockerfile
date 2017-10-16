FROM finalduty/archlinux
MAINTAINER Fabien KOCIK <fabien@knf.dyndns.org>
RUN echo "fr_FR.UTF-8 UTF-8" >> /etc/locale.gen
RUN locale-gen
RUN echo "LANG=fr_FR.UTF-8" >> /etc/locale.conf
ENV LANG=fr_FR.UTF-8
RUN pacman -Syu --noconfirm rsyslog vim net-tools automake autoconf make gcc pcre pkg-config
RUN mkdir -p /var/spool/rsyslog
RUN rm -f /etc/rsyslog.conf
ADD rsyslog.conf /etc/

ADD e2guardian /usr/src/e2guardian
WORKDIR /usr/src/e2guardian
RUN ./autogen.sh
RUN ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var
RUN make
RUN make install

EXPOSE 8080
ADD guard.sh /usr/local/bin/
ENTRYPOINT [ "/bin/bash" ]
CMD [ "/usr/local/bin/guard.sh" ]

RUN rm -f /etc/e2guardian/e2guardian.conf
ADD e2guardian.conf /etc/e2guardian/
