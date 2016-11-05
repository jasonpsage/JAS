#!/bin/bash
mysqladmin -uroot -proot shutdown

#tarpup dl version of mariadb
#mkdir /var/run/mysqld
#fatdog version of mariadb
mkdir /run/mysqld/

/usr/sbin/mysqld &
sleep 3
echo ................
echo MariaDB Should be up an running now.
echo ................
xmessage "Success!" -timeout 4
