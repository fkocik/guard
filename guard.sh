#!/bin/bash

shutdown() {
	echo "Shutdown: sending TERM signal to all processes ..."
	GUARD=$(ps -ef | grep e2guardian | grep -v grep | awk '{print $2}')
	SQUID=$(ps -ef | grep squid | grep -v grep | awk '{print $2}')
	LOG=$(ps -ef | grep rsyslogd | grep -v grep | awk '{print $2}')
	while [ ! -z "${GUARD}${SQUID}${LOG}" ]; do
		GUARD=$(ps -ef | grep e2guardian | grep -v grep | awk '{print $2}')
		SQUID=$(ps -ef | grep squid | grep -v grep | awk '{print $2}')
		LOG=$(ps -ef | grep rsyslogd | grep -v grep | awk '{print $2}')
		test -z "$GUARD" || kill -TERM $GUARD
		test -z "$SQUID" || kill -TERM $SQUID
		test -z "$LOG" || kill -TERM $LOG
		sleep 5
	done
	echo "Shutdown accepted: waiting for effective stop ..."
}

trap shutdown INT QUIT TERM
trap "rm -f /var/run/rsyslog.pid" EXIT

rm -f /var/run/rsyslog.pid
rm -f /var/run/squid.pid

echo -n "Starting Log daemon"
rsyslogd
test $? -eq 0 && echo " OK " || echo " Error !"
sleep 1

echo -n "Starting Proxy daemon"
squid -s -l daemon
test $? -eq 0 && echo " OK " || echo " Error !"
sleep 1

echo -n "Starting Guardian daemon"
e2guardian
test $? -eq 0 && echo " OK " || echo " Error !"
sleep 1

while [ 1 ]; do
	sleep 60
	LOG=$(ps -ef | grep rsyslogd | grep -v grep | awk '{print $2}')
	SQUID=$(ps -ef | grep squid | grep -v grep | awk '{print $2}')
	GUARD=$(ps -ef | grep e2guardian | grep -v grep | awk '{print $2}')
	if [ -z "${GUARD}${SQUID}${LOG}" ]; then
		echo "Shutdown detected."
		break
	fi
	if [ -z "$LOG" ]; then
		echo "Log daemon failed ... restarting ..."
		rm -f /var/run/rsyslog.pid
		rsyslogd
	fi
	if [ -z "$SQUID" ]; then
		echo "Proxy server failed ... restarting ..."
		rm -f /var/run/squid.pid
		squid -s -l daemon
	fi
	if [ -z "$GUARD" ]; then
		echo "E2Guardian failed ... restarting ..."
		e2guardian
	fi
done

echo "Shutdown complete"
exit 0

