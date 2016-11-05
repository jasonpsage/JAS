#!/bin/sh
echo This utility combines the source files for IWF into one javascript 
echo file. After you run this. Compress the output file with a javascript 
echo compressor and save the compressed verion of the file as 
echo iwf_compressed.js 
echo Working...
cat iwfcore.js > iwfcomplete.js
cat iwfxml.js >> iwfcomplete.js
cat iwfajax.js.jegas >> iwfcomplete.js
cat iwfgui.js >> iwfcomplete.js
