#!/bin/bash

shutdown() {
	kill -TERM $(ps -ef | grep rsyslogd | grep -v grep | awk '{print $2}')
	rm -f /var/run/rsyslog.pid
}

trap shutdown INT QUIT TERM

rsyslogd
e2guardian -N

