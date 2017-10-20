#!/bin/bash

shutdown() {
	SQUID=$(ps -ef | grep squid | grep -v grep | awk '{print $2}')
	test -z "$SQUID" || kill -TERM $SQUID
	LOG=$(ps -ef | grep rsyslogd | grep -v grep | awk '{print $2}')
	test -z "$LOG" || kill -TERM $LOG
	rm -f /var/run/rsyslog.pid
}

trap shutdown INT QUIT TERM

squid -s -l daemon
rsyslogd
e2guardian -N

shutdown
