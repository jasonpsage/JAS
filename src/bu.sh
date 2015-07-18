#!/bin/sh
mysqldump -uroot -proot jas > ../database/jas.sql
delp .
delp ../software/synapse/source/lib/.
mkdir /var/jasbu
./jegasbackup /var/JegasCRM/ /var/jasbu/
