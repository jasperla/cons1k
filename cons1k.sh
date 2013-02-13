#!/bin/sh
#
# Helper to make life easier dealing with multiple logical
# domains.

conf="cons1k.conf"

if [ `arch -s` != "sparc64" ]; then
    echo "==> Error: host is not running OpenBSD/sparc64"
    exit 1
fi

usage() {
    echo "$0 [ldom name]"
    exit 1
}

if [ ! -r "${conf}" ]; then
    echo "==> Error: cannor read config file: ${conf}."
    exit 1
fi

if [ -z $1 ]; then
    usage
else
    grep -qw $1 ${conf} || usage
    ldom=$1
fi

configuration=$(grep -w ${ldom} ${conf})
tty=$(echo ${configuration} | awk '{print $2}')
vnet=$(echo ${configuration} | awk '{print $3}')

if [ ! -r "/dev/${tty}" ]; then
    echo "==> Error: /dev/${tty} does not exist."
    exit 1
fi

tmux new-session -s cons1k -d
echo "==> Connecting to ${ldom} on /dev/${tty}"
tmux neww -t cons1k -n ${ldom} "cu -l ${tty}"
tmux attach-session -t cons1k
