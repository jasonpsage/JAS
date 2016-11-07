- - - - - - - - - - - - - - - - - - - - 
DOWNLOAD JAS and JegasAPI Git Projects
- - - - - - - - - - - - - - - - - - - - 

Place both projects into a directory named jegas in the root of your filesystem. It can be moved later, when you want to go through the /jegas/jas/config/jas.cfg file and change the directory location. 

For this how to, you need both JAS and JegasAPI projects. When you have them configured right you should have:

linux:
/jegas/
/jegas/jas/
/jegas/api/

windows:
c:\jegas\
c:\jegas\jas\
c:\jegas\api\








- - - - - - - - - - - - - - - - - - - - 
MySQL Server and Client
- - - - - - - - - - - - - - - - - - - - 

Next you need to install MySQL or MariaDB SQL server as well as the client library. Note that database can be a pain in some configurations. On some Linux I am unable to get even identical library mariadb-client versions to connect on some Linux Distros; again same exact everything but different linux kernel and no happy dance! 

If JAS (JegasCRM) is hanging in the very beginning its usually a database issue:
missing the mysql client files, the database is simply off, or that nasty
bit I described above; I've run into that connect problem a few times now
on FreePascal 3.0.0 and it seems to be distro specific but I haven't nailed
down what they have in common so the problem remains.

These Worked when I tried them out but for all I know a kernel update might be the straw that breaks the proverbial camel's back.

===============
    64 Bit 
===============
Windows 7, 8 and 10
CentOS-7
KuBuntu 15.04
Fedora 22
Slackware 14.1
FatDog
Point Linux Mate Core 2.3.1-64
KaOS-2015.04-x86_64
Mageia 4.1 x86_64
PC Linux OS 64
LuBuntu 15.04 Desktop amd64
SUSE Linux Enterprise Server 12
BackBox 4.x
Linux Mint 17.3
tahrPuppy 6.0.5


- - - - - - - - - - - - - - - - - - - - 
Install FreePascal – If you plan to compile JAS
- - - - - - - - - - - - - - - - - - - - 
Download Freepascal 3.0.0 for your architecture from www.freepascal.org
Installing it with the defaults tends to work.
Providing you set up your project folders as mentioned above, you can execute the following commands to configure your FreePascal to be aware of the JegasAPI and the location of the MySQL library (which is presumed to be /usr/lib/libmysqlclient.so).

Linux: cat /jegas/jas/src/fpclinux.cfg >> /etc/fpc.cfg

Windows - type c:\jegas\src\fpcwin.cfg >> c:\fpc\[version]\[bin folder]\fpc.cfg
(Navigate to your windows FreePascal installation and locate the fpc.cfg file yourself, using this example above, and make sure the exact location is correct as you will need to put in the exact path here and not my psuedo paths in brackets.





- - - - - - - - - - - - - - - - - - - 
Configuring JAS
- - - - - - - - - - - - - - - - - - - 
Add the Jas User (and an empty JAS database):

  Linux: mysql -uroot -proot < /jegas/jas/database/keep/user-jas.sql

  Windows: mysql -uroot -proot < c:\jegas\jas\database\keep\user-jas.sql

Add the Stock Database:

  Linux: mysql -uroot -proot < /jegas/jas/database/keep/jas-stock.sql

  Windows:  mysql -uroot -proot < c:\jegas\jas\database\keep\jas-stock.sql

Next make /jegas/jas/bin your current working directory and run ./jas in linux and just jas in windows. Its Running if everything lines up! 

Now What? Open a browser to http://localhost/ and login as admin without a password – now the fun begins!









--Jason - Jegas,LLC - www.jegas.com
