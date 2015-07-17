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
// This was more of a scratch version - but I found it
// useful both in testing and as a reference.
//
// This test app writes out using JFILESYS, and the WriteStream
// call
program test_ug_jfilesys_02;
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
  ach: array [0..122] of char;
  i: LongInt;
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
    for i:=0 to 122 do ach[i]:='-';
    ach[119]:='S';
    ach[120]:='A';
    ach[121]:='G';
    ach[122]:='E';
    i:=119;
    if bJFSWriteStream(rJFSFile,@aCH,i) then
    Begin
      Writeln('Streamed it out');
    End;
    
    i:=4;
    if bJFSWriteStream(rJFSFile,@aCH[119],i) then
    Begin
      Writeln('Streamed it out');
    End;

    i:=0;
    if bJFSWriteStream(rJFSFile,@aCH[119],i) then
    Begin
      Writeln('Streamed it out');
    End;

    ach[119]:='W';
    ach[120]:='E';
    ach[121]:='L';
    ach[122]:='P';
    i:=4;
    if bJFSWriteStream(rJFSFile,@aCH[119],i) then
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
  
//=============================================================================
End.
//=============================================================================

//*****************************************************************************
// EOF
//*****************************************************************************

