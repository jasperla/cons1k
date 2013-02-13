Cons1k
======

This is a simple helper script which takes away the need for you to
remember which console port to use for which logical domain as
configured on a capable [OpenBSD/sparc64](http://openbsd.org/sparc64.html)
machine.

The console information is gathered from the _dmesg_ and console
sessions are managed in a [tmux](http://tmux.sf.net) window.

Usage
-----

Assuming you've got a logical domain configured ([HOWTO](http://undeadly.org/cgi?action=article&sid=20121214153413))
and named it "ports", use _cons1k.sh_ as easy as:

	cons1k.sh ports

This will create a new tmux window named _ports_ and start a new tmux
sesison named _cons1k_ or attach it to an existing _cons1k_ session.

Naming
------

_cons1k_ was written for my Sun T1000, hence the obvious name.

License
-------

Copyright (c) 2013 Jasper Lievisse Adriaanse <jasper@humppa.nl>
Distributed under the MIT/X11 license (see the copyright notice in cons1k.sh)
