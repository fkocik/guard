#!/bin/bash

# Main KNF Guard startup script

echo "  #########################"
echo " #                       ##"
echo "######################### #"
echo "#                       # #"
echo "#       KNF Guard       # #"
echo "#                       # #"
echo "##########################"
echo
echo "Version: $GUARD_VERSION"
echo
echo "System locale information:"
locale | sed 's/^/    /'
echo "System date/time: $(date)"
echo "Loading KNF Init system ..."
exec knfinit logger.sh squid.sh e2guardian.sh

