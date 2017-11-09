#!/bin/bash

# RSyslog daemon launcher

if [ -f /var/run/rsyslogd.pid ]; then
	echo -n "Removing stalled PID file ..."
	rm -f /var/run/rsyslogd.pid && echo " done" || echo " Failed !"
fi

exec rsyslogd -n

