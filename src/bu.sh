#!/bin/sh
mysqldump -uroot -proot jas > ../database/jas.sql
delp .
delp ../software/synapse/source/lib/.
./jegasbackup /var/jas/ /var/jasbu/
