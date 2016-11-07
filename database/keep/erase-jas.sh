#!/bin/sh
echo -=-
echo -=-
echo -=-
echo -=-
echo ============= !!! WIPE JAS INSTALLATION !!! ================
echo ============= !!! WIPE JAS INSTALLATION !!! ================
echo ============= !!! WIPE JAS INSTALLATION !!! ================
echo ============= !!! WIPE JAS INSTALLATION !!! ================
echo ONLY RUN SCRIPT FROM INSIDE /jegas/database/keep/
echo PREPARE A FRESH erase-jas.sql file here prior to execution.
echo SEE JAS DATABASE-MASTER UTILITY TO ERASE\/SCRUB YOUR JAS DB.
echo ============================================================
read -r -p "WIPE JAS INSTALLATION? [y/N] " response
case $response in
    [yY][eE][sS]|[yY])
        #echo "Yes!!"
        rm -Rf ../../file/*
        rm -Rf ../../cache/*
        rm -Rf ../../log/*
        rm -f ../../database/*
        rm -f ../../src/*.sql
        # Use JAS Scrub Database utility for this - its maintained.
        #mysqldump -uroot -proot jas > /root/jas-preerased.sql
        #mysql -uroot -proot < erase-jas.sql
        echo You\'re previous database was preserved in \/root\/jas-preerased.sql
        ;;
    *)
        #echo "No!!"
        ;;
esac
xmessage "All done with Erase"




