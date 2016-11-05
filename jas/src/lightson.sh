#!/bin/sh
echo lightson - make sure they are off
killall -9 lighttpd

echo lightson - turning them ON
lighttpd -f /etc/lighttpd/lighttpd.conf

