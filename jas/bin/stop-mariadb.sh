#!/bin/bash
mysqladmin -uroot -proot shutdown
echo ...............
echo Allowing MYSQL to Shut-Down
sleep 3
xmessage "Success!" -timeout 1

