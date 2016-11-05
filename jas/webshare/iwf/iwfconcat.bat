@echo off
echo This utility combines the source files for IWF into one javascript 
echo file. After you run this. Compress the output file with a javascript 
echo compressor and save the compressed verion of the file as 
echo iwf_compressed.js 
echo Working...
type iwfcore.js > iwfcomplete.js
type iwfxml.js >> iwfcomplete.js
type iwfajax.js.jegas >> iwfcomplete.js
type iwfgui.js >> iwfcomplete.js
