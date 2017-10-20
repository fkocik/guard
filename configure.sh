#!/bin/bash

# Configure UT1 lists integration

for LIST in $(find /etc/e2guardian/lists/blacklists -type f -iname 'usage' -printf '%p\n'); do
	FLAVOR=$(sed -n '/^\s*#/d; 1p' $LIST)
	LIST=$(dirname $LIST)
	case "$FLAVOR" in
		black) FLAVOR=banned;;
		white) FLAVOR=grey;;
		*) FLAVOR=banned;;
	esac
	for DATA in domains expressions urls; do
		case $DATA in
			domains) REF=sitelist;;
			urls) REF=urllist;;
			*) REF=regexpurllist;;
		esac
		if [ ! -z "$REF" ]; then
			if [ -f $LIST/$DATA ]; then
				echo "${FLAVOR}${REF}: Adding - $(basename $LIST)/$DATA"
				echo ".Include<$LIST/$DATA>" >> /etc/e2guardian/lists/${FLAVOR}${REF}
			fi
		fi
	done
done

