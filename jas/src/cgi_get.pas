{=============================================================================
|    _________ _______  _______  ______  _______             Get out of the  |
|   /___  ___// _____/ / _____/ / __  / / _____/               Mainstream... |
|      / /   / /__    / / ___  / /_/ / / /____                Jump into the  |
|     / /   / ____/  / / /  / / __  / /____  /                   Jetstream   |
|____/ /   / /___   / /__/ / / / / / _____/ /                                |
/_____/   /______/ /______/ /_/ /_/ /______/                                 |
|         Virtually Everything IT(tm)                         info@jegas.com |
==============================================================================
                       Copyright(c)2016 Jegas, LLC
=============================================================================}

//=============================================================================
{}
// This is a very simple CGI program that is both useful and valuable as a
// simple example of a binary program designed for use as a CGI application.
// (Common Gateway Interface - Some argue- not great, some argue its the most
// secure way to go. I like their portability: thay work on most all web
// servers. Solid technology that can be used for anything without needing to
// hook into a specific "brand" of webserver.
// This program returns the name/value pairs back to the sender in basic html.
program cgi_get;
//=============================================================================

//=============================================================================
// GLOBAL DIRECTIVES
//=============================================================================
{$INCLUDE i_jegas_splash.pp}
//=============================================================================



//=============================================================================
uses strings,{$IFDEF LINUX}linux,{$ENDIF}dos;
//=============================================================================

//=============================================================================
const max_data = 1000;
//=============================================================================

//=============================================================================
type datarec = record
  name,value : string;
  end;
//=============================================================================

//=============================================================================
var data : array[1..max_data] of datarec;
    i,nrdata : longint;
    p  : PChar;
    literal,aname : boolean;
    sa: ansistring;
//=============================================================================

//=============================================================================
begin
//=============================================================================
  Writeln ('Content-type: text/html');
  Writeln;
  p:=getmem(8192);
  //strcopy(p,@GetEnv('QUERY_STRING'));
  sa:=GetEnv('QUERY_STRING');
  writeln(sa);
  strcopy(p,PCHAR(sa));
  nrdata:=1;
  aname:=true;
  data[1].name:='';

  while p^<>#0  do
    begin
    literal:=false;
    if p^='\' then
       begin
       literal:=true;
       inc(pointer(p));
       end;
    if ((p^<>'=') and (p^<>'&')) or literal then
       with data[nrdata] do
          if aname then name:=name+p^ else value:=value+p^
    else
       begin
       if p^='&' then
           begin
           inc (nrdata);
           aname:=true;
           end
        else
           aname:=false;
        end;
    inc(pointer(p));
    end;
  Writeln ('<H1>Form Results :</H1>');
  Writeln ('You submitted the following name/value pairs :');
  Writeln ('<UL>');
  for i:=1 to nrdata do writeln ('<LI> ',data[i].name,' = ',data[i].value);
  Writeln ('</UL>');
//=============================================================================
end.
//=============================================================================

//*****************************************************************************
// EOF
//*****************************************************************************
