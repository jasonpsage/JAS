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
// I found this useful during testing as as a reference
// Jason P Sage
// This test app writes out using JFILESYS, and the WriteStream
// call and then reads it back in.
program test_ug_jfilesys_03;
//=============================================================================

//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_splash.pp}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}
//=============================================================================


//=============================================================================
uses
//=============================================================================
  ug_common,
  ug_jfilesys;
//=============================================================================

//=============================================================================
var
//=============================================================================
  sa: AnsiString;
  rJFSFile: rtJFSFile;
  ach: array [0..119] of char;
  i: integer;
  u4: LongWord;
//=============================================================================

//=============================================================================
Begin
//=============================================================================
  InitJFS(rJFSFile);
  rJFSFile.saFilename:='c:\fifo_cgiin\!testerr.bin';
  rJFSFile.u1Mode:=cnJFSMode_Write;
  if bJFSOpen(rJFSFile) then
  Begin
    Writeln('opened:',rJFSFile.saFilename, ' mode:',rJFSFile.u1Mode);
    if bJFSSeek(rJFSFile,2) then Writeln('Seeked Past Header Record');
    for i:=0 to 119 do ach[i]:='?';
    i:=117;
    if bJFSWriteStream(rJFSFile,@aCH,i) then
    Begin
      Writeln('Streamed it out');
    End;
    
    i:=sizeof(i);
    Writeln('SIZEOF I IS:',sizeof(i));
    if bJFSWriteStream(rJFSFile,@i,i) then
    Begin
      Writeln('Streamed it out');
    End;


    if bJFSWriteBufferNow(rJFSFile) then
    Begin
      Writeln('Flushed the buffer');
    End;
  End;
  if bJFSClose(rJFSFile) then 
  Begin
    Writeln('Closed OK');
  End
  else
  Begin
    Writeln('Um.. has issues with closing.');
  End;

  Writeln('-----------OK Wrote it.. let''s open''r back up--------');
  
  InitJFS(rJFSFile);
  rJFSFile.saFilename:='c:\fifo_cgiin\!testerr.bin';
  rJFSFile.u1Mode:=cnJFSMode_Read;
  if bJFSOpen(rJFSFile) then
  Begin
    Writeln('opened:',rJFSFile.saFilename, ' mode:',rJFSFile.u1Mode);
    //if bJFSSeek(rJFSFile,2) then Writeln('Seeked Past Header Record');
    //if bJFSFastRead(rJFSFile) then Writeln('Um, Fast Read Worked');
    //if bJFSFastRead(rJFSFile) then Writeln('Um, Fast Read Worked');
    if bJFSMoveNext(rJFSFile) then Writeln('MoveNext Worked');
    if bJFSMoveNext(rJFSFile) then Writeln('MoveNext Worked');
    for i:=0 to 119 do ach[i]:='@';
    u4:=117;
    if bJFSReadStream(rJFSFile,@aCH,u4) then
    Begin
      Writeln('Streamed it in');
    End;
    
    u4:=sizeof(i);
    Writeln('SIZEOF I IS:',sizeof(i));
    if bJFSReadStream(rJFSFile,@i,u4) then
    Begin
      Writeln('Streamed it in #2, read i as:',i);
    End;


    //if bJFSWriteBufferNow(rJFSFile) then
    //Begin
    //  Writeln('Flushed the buffer');
    //End;
  End;
  if bJFSClose(rJFSFile) then 
  Begin
    Writeln('Closed OK');
  End
  else
  Begin
    Writeln('Um.. has issues with closing.');
  End;
//=============================================================================
End.
//=============================================================================

//*****************************************************************************
// EOF
//*****************************************************************************

