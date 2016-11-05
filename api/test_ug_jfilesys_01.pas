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
// Test Jegas Filesystem
program test_ug_jfilesys_01;
//=============================================================================

                                                                      
//=============================================================================
// Global Directives                                                  
//=============================================================================
{$INCLUDE i_jegas_splash.pp}
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='test_uxxg_jfilesys_01.pas'}
{$SMARTLINK ON}
{$PACKRECORDS 4}                                                      
{$MODE objfpc}                                                        
//=============================================================================


                                                                      
//=============================================================================
uses                                                                  
//=============================================================================
  ug_common
 ,ug_jfilesys
 ,dos
 ,sysutils
 ;
//=============================================================================


//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !@!Declarations 
//*****************************************************************************
//=============================================================================
//*****************************************************************************
var
  guMaxRecords: uint;
  gsaFilename: ansistring;



//=============================================================================
// make a file - has a header record, and then its written again with a slight
// edit to the buffer before writing it out and closing the file.
function bTest_A: boolean;
//=============================================================================
var
  rJFSFile: rtJFSFile;
  bOk: boolean;
begin
  writeln('================ TEST A =================');
  bOk:=true;

  if bok then
  begin
    JFSClearFileInfo(rJFSFile);// 1: check 2: check
    rJFSFile.saFilename:=gsaFilename;//3: check
    rJFSFile.u1Mode:=cnJFSMode_Write;
    rJFSFile.u4RecSize:=1024;
    bOk:=bJFSOpen(rJFSFile);
    if not bOk then
    begin
      writeln('bJFSOpen FAILED');
    end;
  end;


  if bOk then
  begin
    rtJFSHdr(rJFSFile.lpRecord^).u4RecType:=cnJFS_RecType_Header;
    rtJFSHdr(rJFSFile.lpRecord^).s:='***TESTING JFILESYS***';
    bOk:=bJFSFastAppend(rJFSFile);
    if not bOk then
    begin
      writeln('1st bJFSFastAppend call failed');
    end;
  end;

  if bOk then
  begin
    bOk:=bJFSWriteBufferNow(rJFSFile);
    if not bOk then
    begin
      writeln('1st bJFSWriteBufferNow call failed.');
    end;
  end;

  JFSClose(rJFSFile);
  result:=bOk;
end;
//=============================================================================











//=============================================================================
// verify that the records in test_a saved as expected
function bTest_B: boolean;
//=============================================================================
var
  rJFSFile: rtJFSFile;
  bOk: boolean;
  b: boolean;//temp
begin
  writeln('================ TEST B =================');
  bOk:=true;

  if bok then
  begin
    JFSClearFileInfo(rJFSFile);// 1: check 2: check
    rJFSFile.saFilename:=gsaFilename;//3: check
    rJFSFile.u1Mode:=cnJFSMode_Read;
    rJFSFile.u4RecSize:=1024;
    bOk:=bJFSOpen(rJFSFile);
    if not bOk then
    begin
      writeln('bJFSOpen for read FAILED');
    end;
  end;


  if bOk then
  begin
    bOk:= NOT bJFSEOF(rJFSFile);
    if not bOk then
    begin
      writeln('EOF - Test 1 - Failed.');
    end;
  end;



  if bOk then
  begin
    bOk:=bJFSFastRead(rJFSFile);
    if not bOk then
    begin
      writeln('1st Fastread failed.');
    end;
  end;

  if bOk then
  begin
    bOk:=LeftStr(rtJFSHdr(rJFSFile.lpRecord^).s,5)='Jegas';
    if not bOk then
    begin
      writeln('Load 1 u4Recsize:',rJFSFile.u4RecSize,' Bad Data? Data:',rtJFSHdr(rJFSFile.lpRecord^).s);
    end;
  end;

  if bOk then
  begin
    bOk:= bJFSEOF(rJFSFile);
    if not bOk then
    begin
      writeln('EOF - Test 2 - Failed.');
    end;
  end;


  if bOk then
  begin
    bOk:=bJFSFastRead(rJFSFile);
    if not bOk then
    begin
      writeln('2nd Fastread failed.');
    end;
  end;

  if bOk then
  begin
    bOk:=LeftStr(rtJFSHdr(rJFSFile.lpRecord^).s,5)='***TE';
    if not bOk then
    begin
      writeln('Load 2 u4Recsize:',rJFSFile.u4RecSize,'Bad Data? Data:',rtJFSHdr(rJFSFile.lpRecord^).s);
    end;
  end;

  JFSClose(rJFSFile);
  result:=bOk;
end;
//=============================================================================




















//=============================================================================
// Make new file, make 5 records, navigate, write, navigate, write, etc.
// movefirst, last, previous (if we can), next :)
function bTest_C: boolean;
//=============================================================================
var
  rJFSFile: rtJFSFile;
  bOk: boolean;
  b: boolean;//temp
  u: uint;
begin
  writeln('================ TEST C =================');
  bOk:=true;
  deletefile(gsaFilename);
  bOK:=FileExists(gsaFilename)=false;
  if not bOk then
  begin
    writeln('unable to remove test file: ',gsaFilename);
  end;

  if bok then
  begin
    JFSClearFileInfo(rJFSFile);// 1: check 2: check
    rJFSFile.saFilename:=gsaFilename;//3: check
    rJFSFile.u1Mode:=cnJFSMode_Write;
    rJFSFile.u4RecSize:=48;
    bOk:=bJFSOpen(rJFSFile);
    if not bOk then
    begin
      writeln('bJFSOpen for read FAILED');
    end;
  end;


  if bOk then
  begin
    for u:=1 to 14 do
    begin
      rtJFSHdr(rJFSFile.lpRecord^).u4RecType:=cnJFS_RecType_Header;
      rtJFSHdr(rJFSFile.lpRecord^).u4RecSize:=1234;//doesn't matter here - using the "type" or structure like a recycled bbottle for testing ...brb

      rtJFSHdr(rJFSFile.lpRecord^).s:=leftstr('RECORD DATA for RECORD '+inttostr(u)+' '+saRepeatchar('=',50),rJFSFile.u4RecSize-8);
      bOk:=bJFSFastAppend(rJFSFile);//  <--- fills buffer, buffer can have many records, kinda a counter - need to see if its more....(writes when full i know)
      if not bOk then
      begin
        writeln('TestC - Fastread ',u,' failed.');
        break;
      end;
    end;
  end;

  if bOk then
  begin
    bOk:=bJFSWriteBufferNow(rJFSFile);
    if not bOk then
    begin
      writeln('TestC- bJFSWriteBufferNow call failed.');
    end;
  end;

  JFSClose(rJFSFile);
  result:=bOk;
end;
//=============================================================================











//=============================================================================
// Initialization
//=============================================================================
Begin
  gsaFilename:='test.bin';
  writeln('Test Init...');
  deletefile(gsafilename);
  if fileexists(gsafilename) then
  begin
    writeln('Unable to remove file for testing: '+gsaFilename);
  end
  else
  begin
    if not bTest_A then writeln('bTest_A failed')else
    if not bTest_B then writeln('Got Coffee? You''re going to need it bro') else
    if not bTest_C then writeln('Five Records and navigation...what is the problem?') else
      writeln('PASSED! Hammer Time =|:^)>');
  end;
End.
//=============================================================================


//*****************************************************************************
// eof
//*****************************************************************************
