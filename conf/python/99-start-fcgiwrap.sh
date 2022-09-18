#!/bin/sh
/etc/init.d/fcgiwrap
[ -e /tmp/cgi.sock ] && chmod 777 /tmp/cgi.sock
