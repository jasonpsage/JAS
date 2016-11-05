{=============================================================================
|    _________ _______  _______  ______  _______  Get out of the Mainstream, |
|   /___  ___// _____/ / _____/ / __  / / _____/    Mainstream Jetstream!    |
|      / /   / /__    / / ___  / /_/ / / /____         and into the          |
|     / /   / ____/  / / /  / / __  / /____  /            Jetstream! (tm)    |
|____/ /   / /___   / /__/ / / / / / _____/ /                                |
/_____/   /______/ /______/ /_/ /_/ /______/                                 |
|         Virtually Everything IT(tm)                        Jason@Jegas.com |
==============================================================================
                       Copyright(c)2016 Jegas, LLC
=============================================================================}


//=============================================================================
{ }
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
{$INCLUDE i_jegas_macros.pp}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}
//=======================================================g======================


//=============================================================================
uses
//=============================================================================
  ug_common,
  sysutils,
  ug_jfilesys;
//=============================================================================

const csTestFilename = 'test.bin';


//=============================================================================
var
//=============================================================================
  sa: AnsiString;
  rJFSFile: rtJFSFile;
  ach: array [0..119] of char;
  i: integer;
  u: UInt;
  bOK: Boolean;
//=============================================================================

//=============================================================================
Begin
//=============================================================================
  JFSClearFileInfo(rJFSFile);
  rJFSFile.saFilename:=csTestFilename;
  rJFSFile.u1Mode:=cnJFSMode_Write;
  bOk:=bJFSOpen(rJFSFile);
  if not bok then
  begin
    writeln('Unable to open rJFSFile.saFilename: '+rJFSFile.saFilename);
  end;

  if bOk then
  begin
    bOk:=bJFSSeek(rJFSFile,2);
    if not bOk then
    begin
      Writeln('Unable to seek past the header record:',rJFSFile.saFilename, ' mode:',rJFSFile.u1Mode);
    end;
  end;

  if bOk then
  begin
    for i:=0 to 119 do ach[i]:='?';
    i:=117;
    bOk:=bJFSWriteStream(rJFSFile,@aCH,i);
    if not bOk then
    begin
      Writeln('Unable to stream out data.');
    End;
  end;

  if bOk then
  begin
    i:=sizeof(i);
    //riteln('SIZEOF I IS:',sizeof(i));
    bOk:=bJFSWriteStream(rJFSFile,@i,i);
    if not bOk then
    begin
      Writeln('Unable to stream. The native size of a '+
        '"FreePascal Integer" datatype in this system is:',sizeof(i));
      writeln('(sizeof FPC function returns size datatype uses in ram)');
    end;
  end;

  if bOk then
  begin
    ach[0]:='-';
    ach[1]:='+';
    ach[2]:='H';
    ach[3]:='I';
    ach[4]:='+';
    ach[5]:='Y';
    ach[6]:='O';
    ach[7]:='=';
    i:=8;
    bOk:=bJFSWriteStream(rJFSFile,@aCH,i);
    if not bOk then
    begin
      Writeln('Unable to stream out data. attempt 2');
    End;
  end;

  if bOk then
  begin
    sa:='Ok stream this long thing... just send all this out tacked to the ongoing spill over record filler this stream thingy is.... cmon now....';
    sa+=sa;sa+=sa;
    sa+=sa;sa+=sa;
    sa+=sa;sa+=sa;

    i:=length(sa);
    bOk:=bJFSWriteStream(rJFSFile,PCHAR(sa),i);
    if not bOk then
    begin
      Writeln('Unable to stream out data. attempt 2');
    End;
  end;




  if bOk then
  begin
    bOk:=bJFSWriteBufferNow(rJFSFile);
    if not bOk then
    Begin
      Writeln('Unable to write the file buffer.');
    End;
  End;
  JFSClose(rJFSFile);

  if bOk then
  begin
    //riteln('-----------OK Wrote it.. let''s open''r back up--------');
    JFSClearFileInfo(rJFSFile);
    rJFSFile.saFilename:=csTestFilename;
    rJFSFile.u1Mode:=cnJFSMode_Read;
    bOk:=bJFSOpen(rJFSFile);
    if not bOk then
    begin
      writeln('Unable to open for reading: ',rJFSFile.saFilename);
    end;
  end;

  if bOk then
  Begin
    //riteln('opened:',rJFSFile.saFilename, ' mode:',rJFSFile.u1Mode);
    //if bJFSSeek(rJFSFile,2) then Writeln('Seeked Past Header Record');
    //if bJFSFastRead(rJFSFile) then Writeln('Um, Fast Read Worked');
    //if bJFSFastRead(rJFSFile) then Writeln('Um, Fast Read Worked');
    //riteln('b4 1st movenext bOk:',sYesNo(bOk),' - Data: ',rtJFSHdr(rJFSFile.lpRecord^).s);
    bOk:=bJFSMoveNext(rJFSFile);
    if not bOk then
    begin
     Writeln('The first bJFSMoveNext call failed.');
     writeln('1st movenext bOk:',sYesNo(bOk),' - Data: ',rtJFSHdr(rJFSFile.lpRecord^).s);
    end;
  end;

  if bOk then
  begin
    bOk:=bJFSMoveNext(rJFSFile);
    if not bOk then
    begin
      Writeln('The second bJFSMoveNext call failed.');
      writeln('2nd movenext bOk:',sYesNo(bOk),' - Data: ',rtJFSHdr(rJFSFile.lpRecord^).s);
    end;
  end;

  if bOk then
  begin
    for i:=0 to 119 do ach[i]:='@';
    u:=117;
    bOk:=bJFSReadStream(rJFSFile,@aCH,u);
    if not bOk then
    Begin
      Writeln('The first bJFSReadStream call failed.');
    End;

  end;

  if bOk then
  begin
    for i:=0 to 116 do
    begin
      bOk:=ach[i]='?';
    end;
    if not bOk then
    begin
      writeln('The data read is not what was expected.');
    end;
  end;


  if bOk then
  begin
    for i:=117 to 119 do
    begin
      bOk:=ach[i]='@';
      if not bOk then break;
    end;
    if not bOk then
    begin
      writeln('The data read back came back incorrectly (byte positions 117 thru 119).');
    end;
  end;


  if bOk then
  begin
    //for i:=0 to 119 do write(ach[i]);
    u:=sizeof(i);
    //Writeln('SIZEOF I IS:',sizeof(i));
    bOk:= bJFSReadStream(rJFSFile,@i,u);
    if not bOk then
    begin
      Writeln('The first bJFSReadStream call failed. The Native "SizeOf" the '+
        'FPC Integer datatype in this system, in bytes, is: ',u);
    end;
  end;
  JFSClose(rJFSFile);
  writeln('All Tests Passed: ',sYesNo(bOk));
  //deletefile(csTestFilename);
//=============================================================================
End.
//=============================================================================

//*****************************************************************************
// EOF
//*****************************************************************************

