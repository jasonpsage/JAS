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
{ }
// This is just a test program to show how to get data and time from POSIX and
// windows. Additionally there is a Jegas Date Test "JDate" call.
// You get a variety of date stuff to look at in a hurry.
program testdate;
{$MODE objfpc}
//=============================================================================

//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
//=============================================================================



//=============================================================================
uses
//=============================================================================
 ug_misc,
 ug_jegas,
 ug_common,
 crt,
 sysutils,
 {$ifdef linux}
 baseunix,
 unix,
 termio, // serial
 linux,
 dateutils,
 unixutil;
 {$else}
 windows;
 {$endif}
//=============================================================================


//=============================================================================
procedure mylo_os_gettime( var hour , minute , second , sec1000 : word );
//=============================================================================
var
  {$ifdef linux}  // LINUX
   datetime : tdatetime;
  {$else}
   st : systemtime;
  {$endif}
begin
  {$ifdef linux} // LINUX
    datetime := time;
    hour     := hourof( datetime );
    minute   := minuteof( datetime );
    second   := secondof( datetime );
    sec1000  := millisecondof( datetime );
  {$else}        // WINDOWS
    getlocaltime( st );
    hour    := st.whour;
    minute  := st.wminute;
    second  := st.wsecond;
    sec1000 := st.wmilliseconds;
  {$endif}
end;
//=============================================================================

//=============================================================================
procedure mylo_os_getdate( var year , month , day : word );
//=============================================================================
var
  {$ifdef linux}
    datetime : tdatetime;
  {$else}
    st : systemtime;
  {$endif}
begin
  {$ifdef linux}
    datetime := date;
    year     := yearof( datetime );
    month    := monthof( datetime );
    day      := dayof( datetime );
  {$else}
    getlocaltime( st );
    year   := st.wyear;
    month  := st.wmonth;
    day    := st.wday;
  {$endif}
end;
//=============================================================================


//=============================================================================
function bTestJDate: boolean;
//=============================================================================
var
  saSync_VTDT: ansistring;
  saSync_JASDT: ansistring;
  saSync_SyncDT: ansistring;
  dtSync_VTDT: TDATETIME;
  dtSync_JASDT: TDATETIME;
  dtSync_SyncDT: TDATETIME;
  dt: TDATETIME;
begin
  result:=false;

// LAME but shuts up compiler warnings
  saSync_VTDT   :='';
  saSync_JASDT  :='';
  saSync_SyncDT :='';
  dtSync_VTDT   := now;
  dtSync_JASDT  := now;
  dtSync_SyncDT := now;
  dt            := now;




  saSync_VTDT:='2010-06-30 16:44:17';
  saSync_JASDT:='2010-07-01 05:50:21';
  saSync_SyncDT:='2010-07-01 05:50:21';


//Const csDateFormat_00='?';
//const cnDateFormat_00=0;//< 0 for when you pass DATE OBJECT, use this as format in, just so routine doesn't kick you out.
//Const csDateFormat_11='YYYY-MM-DD HH:NN:SS';
//const cnDateFormat_11=11; //<11 '2005-01-30 14:15:12'

  //     string in     format out    format in      dateobject
  JDATE(saSync_VTDT,cnDateFormat_00,cnDateFormat_11,dtSync_VTDT);
  
  dt:=now;
  
  writeln(saSync_VTDT,' ',formatdatetime(csDATETIMEFORMAT24,dtSync_VTDT));
  writeln('Now',' ',formatdatetime(csDATETIMEFORMAT24,now));



  //made it here? YAY no explosion? YAY Ok is GOOD!
  result:=true;
end;
//=============================================================================


//=============================================================================
var
  bOk: boolean;
  year , month , day : word;
  hour , minute , second , sec1000 : word;
begin
//=============================================================================
  //writeln(date);
  //writeln(datetimetounix(now));


  mylo_os_getdate( year , month , day);
  writeln('mylo_os_getdate(',year,', ',month,' , ',day,');');
  mylo_os_gettime( hour , minute , second , sec1000);
  writeln('mylo_os_gettime(',hour,', ',minute,', ',second,', ',sec1000,');');
  writeln('Calling bTestJDate');
  bOk:=bTestJDate;
  if not bOk then
  begin
    writeln('bTestJDate failed.');
  end;

  if bOk then
  begin
  end;
end.
//=============================================================================

//*****************************************************************************
// EOF
//*****************************************************************************
