#!/bin/sh
/etc/init.d/fcgiwrap /tmp/cgi.sock 2
[ -e /tmp/cgi.sock ] && chmod 777 /tmp/cgi.sock
