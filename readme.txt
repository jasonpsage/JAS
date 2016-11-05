Tested on the following operating systems:

===============
    32 Bit 
===============
Windows XP                     
===============


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
===============


Unfortunately JAS does not run on 32 Bit Linux any longer. Something has 
changed in the inards of either FreePascal's MySQL wrapper for the mysql api, 
or the mysql api itself. This may be a marisDB vs. MySQL thing for all I 
know...hmm..just thought of that. Anyways - I want it running in Linux 32bit 
like it used to before who knows what changed.


This program accesses the MySQL api directly, so there needs to be a 
libMySQLclient.so symbolic link or MySQL library file. (In windows you need 
libmysql.dll version 4 or above is best, you can recompile JAS for use with 
MySQL3 if necessary. I haven't tried JAS lately in Lin32 with this library so
I'm not sure if that would work or not, but the 64bit executables seem to 
works all the time everywhere.).

1: Make a database in your MySQL server named, say: jas
then import into it this: ./jas/database/jas.sql

2: Edit ./jas/config/jas.cfg to make sure the ip address, server name are cor-
rect. for now, do not change the server IDENT. IDENT value in config must 
match the IDENT value in the database as a safety precaution for when you
run multiple instances of JAS; this prevents accidentally acessing the wrong
database from a configuration mistake.


3: Ok next you edit the ./jas/config/jas.dbc file... and there you basically 
look for the MySQL username, password and host/ip fields and enter the correct 
values for your system. If you look closely you can see there is an ODBC 
option and it works on windows and should on Linux, but I have not test ODBC
on Linux.


4: Before things will go smoothly, you need read/write privileges on:
./jas/cache 
./jas/file 
./jas/jets 
./jas/log

Note: If JAS is unable to execute ./jas/bin/rmdir.sh on linux, then the cache 
won't get cleared, and JAS won't start up. Make sure the ./jas/bin/ folder's
executables and shell scripts are all executable to be safe. AS ATLEAST:
jas or jas_no_odbc       (Soon names will change to jas32 and jas64 in the 
./jas/bin/ folder so folks who don't wish to compile will have options: 
32/64 bit executables and versions without ODBC support so unixODBC isn't 
required.


Ok - if everything is good, the MySQL daemon is running, jas.cfg and jas.dbc 
are configured, you can go to /jas/bin/ and run an appropriate jas executable.


Before you open a browser, there is one more configuration item.
Edit ./jas/webshare/script/jegas.js   and change the value of 
MAINURL to the url for your installation; please enter the trailing slash as
is shown below. If you are just using the browser on the same machine as 
JegasCRM/JAS then the value here might simply be: http://localhost/


Open a web browser to the URL/IP you setup and you should see JAS.
Username: admin
Password: None - you can set this whenever you like on the login screen.

Lose your password? If you have a person record in jas, attached to your 
username, and that person record has your email in the work email field,
then the recover lost password feature will work. You'll get an email with 
a reset password link.

Wait...You haven't set up your person record with your correct email in 
the work email field and/or have not linked your username record to it yet?
No worries - get into your MySQL (if you can't get in there - I can't help 
you) and execute: 

USE jas;
UPDATE juser SET JUser_Password='' where JUser_Name='YourUserNameHere';

That will make it blank. Best change it after this maneuver unless its a 
development machine! :)


Good Luck! I know there isn't much in the way of documentation but there 
is a directory called help and in there is a complete API reference for 
the entire project. But that doesn't help someone trying to figure out how 
to modify a screen, add fields, hide fields, make security groups, 
assign permissions, add users, add people, companies, projects, how to make 
reminders work that send me emails, how does the calendar work etc... 
to name a few - for now - have a look around and try to get familiar with it.
More help has been added to the web interface... the help icons have been there,
they are just becoming much more useful now!


Development Continues!


Thank You for having a peek at JegasCRM and the Jegas Application Server(JAS)

--Jason Sage
  Owner Jegas, LLC - www.jegas.com and www.jegas.net for hosting.
