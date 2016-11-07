#!/bin/sh
killall -9 "jas"
killall -9 "loopjas.sh"
killall -9 "loop.sh"
killall -9 "lighttpd"

mysqladmin -uroot -proot shutdown
clear
echo JAS - FORCED STOP COMPLETE - JAS is down.
echo MySQL Server Shutdown, but much gentler.
xmessage -file /opt/tahr/msg/success.msg -timeout 1
