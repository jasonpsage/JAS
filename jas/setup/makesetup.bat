@echo off
cd c:\wfiles\code\jas\
wzzip -a -r -p setup\jas_1.0.0.386_bin.zip bin
wzzip -a -r -p setup\jas_1.0.0.386_dev.zip dev
wzzip -a -r -p setup\jas_1.0.0.386_php.zip php
wzzip -a -r -p setup\jas_1.0.0.386_software.zip software
wzzip -a -r -p setup\jas_1.0.0.386_webroot.zip webroot
wzzip -a -r -p setup\jas_1.0.0.386_config.zip config
wzzip -a -r -p setup\jas_1.0.0.386_src.zip src
wzzip -a -r -p setup\jas_1.0.0.386_webshare.zip webshare
wzzip -a -r -p setup\jas_1.0.0.386_cgi-bin.zip cgi-bin
wzzip -a -r -p setup\jas_1.0.0.386_database.zip database
wzzip -a -r -p setup\jas_1.0.0.386_templates.zip templates

