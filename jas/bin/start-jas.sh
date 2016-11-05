#!/bin/bash
cd /jegas/jas/bin

#For Jas
killall -9 jas

#for less accidental open port issues
killall -9 ssh-agent
killall -9 ftpd
killall -9 vsftpd
killall -9 lighttpd

mysqladmin -uroot -proot shutdown
sleep 2

mkdir /run/mysqld
#mkdir /var/run/mysqld

echo ------------------------------------
echo Giving Any previous instance of MYSQL a chance to shut down cleanly
echo ------------------------------------
sleep 3
/usr/sbin/mysqld &
echo ------------------------------------
echo Giving MYSQL time to start up
echo ------------------------------------
sleep 5
echo ------------------------------------
echo JAS TABLE MAINTENANCE - STARTED
mysql -uroot -pRoseIsGreen < /jegas/jas/database/keep/repair-tables.sql > /dev/null
echo JAS TABLE MAINTENANCE - COMPLETE
echo ------------------------------------
lighttpd -f /etc/lighttpd/lighttpd.conf
./jas
mysqladmin -uroot -pRoseIsGreen shutdown


