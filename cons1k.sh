#!/bin/sh
#
# Helper to make life easier dealing with multiple logical
# domains.

# Use the dmesg on disk since the dmesg buffer may have overflowed since boot.
dmesg="/var/run/dmesg.boot"

if [ `arch -s` != "sparc64" ]; then
    echo "==> Error: host is not running OpenBSD/sparc64"
    exit 1
fi

usage() {
    echo "$0 [ldom name]"
    exit 1
}

if [ -z $1 ]; then
    usage
else
    grep -qw ldom-$1 ${dmesg} || usage
    ldom=$1
fi

tty=$(grep domain\ \"${ldom}\" ${dmesg} | awk '{print $1}' | sed 's,vcctty,,g')
tty="/dev/ttyV${tty}"

if [ ! -c "${tty}" ]; then
    echo "==> Error: ${tty} does not exist."
    exit 1
fi

tmux new-session -s cons1k -d
echo "==> Connecting to ${ldom} on ${tty}"
tmux neww -t cons1k -n ${ldom} "sudo cu -l ${tty}"
tmux attach-session -t cons1k
