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

usage()
{
    echo "usage: ${0##*/} [-d ldom | -l]"
    exit 1
}

list_ldoms()
{
    echo "==> Available domains:"
    sed -nE 's,^vcctty.*domain\ \"(.*)\",\1,p' ${dmesg}
    exit 0
}

ldom=
lflag=0
while getopts "ld:" flag; do
    case "$flag" in
	l)    lflag=1 ;;
	d)    ldom=$OPTARG ;;
	*)    usage() ;;
    esac
done

[ $# -gt 0 ] || usage

if [ "${lflag}" -gt "0" ]; then
    list_ldoms
elif [ ! -z ${ldom} ]; then
    grep -qw ldom-${ldom} ${dmesg}
    if [ "$?" -ne 0 ]; then
	echo "==> Error: ${ldom} nog configured."
	exit 1
    fi
fi


tty="/dev/ttyV"$(sed -nE "s,vcctty([[:digit:]])\ .*domain\ \"${ldom}\",\1,p" ${dmesg})

if [ ! -c "${tty}" ]; then
    echo "==> Error: ${tty} does not exist."
    exit 1
fi

tmux new-session -s cons1k -d
echo "==> Connecting to ${ldom} on ${tty}"
tmux neww -t cons1k -n ${ldom} "sudo cu -l ${tty}"
tmux attach-session -t cons1k
