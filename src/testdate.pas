{==============================================================================
|    _________ _______  _______  ______  _______  Jegas, LLC                  |
|   /___  ___// _____/ / _____/ / __  / / _____/  JasonPSage@jegas.com        |
|      / /   / /__    / / ___  / /_/ / / /____                                |
|     / /   / ____/  / / /  / / __  / /____  /                                |
|____/ /   / /___   / /__/ / / / / / _____/ /                                 |
/_____/   /______/ /______/ /_/ /_/ /______/                                  |
|                 Under the Hood                                              |
===============================================================================
                       Copyright(c)2012 Jegas, LLC
==============================================================================}

//=============================================================================
{}
// This is just a test program to put Jegas Date Routines and FreePascal
// date routines through their paces.
program testdate;
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
procedure TestJDate;
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
  saSync_VTDT:='2010-06-30 16:44:17';
  saSync_JASDT:='2010-07-01 05:50:21';
  saSync_SyncDT:='2010-07-01 05:50:21';
    
  JDATE(saSync_VTDT,cnDateFormat_00,cnDateFormat_11,dtSync_VTDT);
  
  dt:=now;
  
  writeln(saSync_VTDT,' ',saformatdatetime(csDATETIMEFORMAT24,dtSync_VTDT));
  writeln('Now',' ',saformatdatetime(csDATETIMEFORMAT24,now));
end;
//=============================================================================


//=============================================================================
begin
//=============================================================================
  //writeln(date);
  //writeln(datetimetounix(now));
  TestJDAte;
end.
//=============================================================================

//*****************************************************************************
// EOF
//*****************************************************************************
