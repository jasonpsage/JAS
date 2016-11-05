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
  sysutils,
  ug_jfilesys;
//=============================================================================

//=============================================================================
var
//=============================================================================
  sa: AnsiString;
  rJFSFile: rtJFSFile;
  ach: array [0..122] of char;
  i: LongInt;
  bOk: boolean;
//=============================================================================


//=============================================================================
Begin
//=============================================================================
  JFSClearFileInfo(rJFSFile);
  rJFSFile.saFilename:='test.bin';
  rJFSFile.u1Mode:=cnJFSMode_Write;
  bOk:=bJFSOpen(rJFSFile);
  if not bOk then
  Begin
    Writeln('unable to open:',rJFSFile.saFilename, ' mode:',rJFSFile.u1Mode);
  end;

  if bOk then
  begin
    bOk:=bJFSSeek(rJFSFile,2);
    if not bOk then
    begin
      Writeln('Attempt to seek past the header record failed.');
    end;
  end;

  if bOk then
  begin
    for i:=0 to 122 do ach[i]:='-';
    ach[119]:='S';
    ach[120]:='A';
    ach[121]:='G';
    ach[122]:='E';
    i:=119;
    bOk:=bJFSWriteStream(rJFSFile,@aCH,i);
    if not bOk then
    Begin
      Writeln('1st bJFSWriteStream call failed.');
    End;
  end;

  if bOk then
  begin
    i:=4;
    bOk:=bJFSWriteStream(rJFSFile,@aCH[119],i);
    if not bOk then
    Begin
      Writeln('2nd bJFSWriteStream call failed.');
    End;
  end;

  if bOk then
  begin
    i:=0;
    bOk:=bJFSWriteStream(rJFSFile,@aCH[119],i);
    if not bOk then
    Begin
      Writeln('3rd bJFSWriteStream call failed.');
    End;
  end;

  if bOk then
  begin
    ach[119]:='W';
    ach[120]:='E';
    ach[121]:='L';
    ach[122]:='P';
    i:=4;
    bOK:=bJFSWriteStream(rJFSFile,@aCH[119],i);
    if not bOk then
    Begin
      Writeln('4th bJFSWriteStream call failed.');
    End;
  end;

  if bOk then
  begin
    bOK:=bJFSWriteBufferNow(rJFSFile);
    if not bOk then
    Begin
      Writeln('bJFSWriteBufferNow call failed.');
    End;
  End;
  JFSClose(rJFSFile);
  deletefile(rJFSFile.safilename);
  Writeln('All Tests Passed: ',sYesNo(bOK));
  
  
//=============================================================================
End.
//=============================================================================

//*****************************************************************************
// EOF
//*****************************************************************************

