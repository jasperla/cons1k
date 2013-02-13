#!/bin/sh
#
# Copyright (c) 2013 Jasper Lievisse Adriaanse <jasper@humppa.nl>
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#
# Helper to make life easier dealing with multiple logical domain consoles.

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
